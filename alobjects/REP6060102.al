report 6060102 "Data Cleanup Process"
{
    // NPR5.23/JC/20160331  CASE 237816 Changed report to a process report
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object
    DefaultLayout = RDLC;
    RDLCLayout = './Data Cleanup Process.rdlc';

    Caption = 'Data Cleanup Process';

    dataset
    {
        dataitem("Data Cleanup GCVI";"Data Cleanup GCVI")
        {
            DataItemTableView = SORTING("Cleanup Action",Type,"No.") ORDER(Ascending) WHERE(IsProcessed=CONST(false),IsApproved=CONST(true),Retries=FILTER(<10));
            column(CleanupAction_DataCleanupCVI;"Data Cleanup GCVI"."Cleanup Action")
            {
            }
            column(Type_DataCleanupCVI;"Data Cleanup GCVI".Type)
            {
            }
            column(No_DataCleanupCVI;"Data Cleanup GCVI"."No.")
            {
            }
            column(Status_DataCleanupCVI;"Data Cleanup GCVI".Status)
            {
            }
            column(Description_DataCleanupCVI;"Data Cleanup GCVI".Description)
            {
            }
            column(Retries_DataCleanupCVI;"Data Cleanup GCVI".Retries)
            {
            }
            column(ProcessResult;ProcessResult)
            {
            }

            trigger OnAfterGetRecord()
            begin

                DataCleanupCVI2.Get("Data Cleanup GCVI"."Cleanup Action", "Data Cleanup GCVI".Type, "Data Cleanup GCVI"."No.");

                if not CODEUNIT.Run(CODEUNIT::"Data Cleanup GCVI Line", DataCleanupCVI2) then begin
                  DataCleanupCVI2.Status      := GetLastErrorText;
                  DataCleanupCVI2.IsError     := true;
                  ProcessResult := false;
                end else begin
                  DataCleanupCVI2.Status      := 'SUCCESS';
                  DataCleanupCVI2.IsDeleted   := true;
                  DataCleanupCVI2.IsProcessed := true;
                  DataCleanupCVI2.Success     := true;
                  ProcessResult := true;
                end;

                if ( not ProcessResult) or (ProcessResult and ("Data Cleanup GCVI".Type = "Data Cleanup GCVI"."Cleanup Action"::Delete)) then begin
                  DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                  DataCleanupCVI2.Modify(true);
                  Commit;
                end else begin
                  DataCleanupCVI2.Get("Data Cleanup GCVI"."Cleanup Action", "Data Cleanup GCVI".Type, "Data Cleanup GCVI"."NewNo.");

                  DataCleanupCVI2.Status      := 'SUCCESS';
                  DataCleanupCVI2.IsDeleted   := true;
                  DataCleanupCVI2.IsProcessed := true;
                  DataCleanupCVI2.Success     := true;
                  ProcessResult := true;

                  DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                  DataCleanupCVI2.Modify(true);
                  Commit;
                end;
            end;

            trigger OnPreDataItem()
            begin
                case CleanupAction of
                  CleanupAction::Delete:
                    begin
                      "Data Cleanup GCVI".SetRange("Approve Delete", true);
                      "Data Cleanup GCVI".SetRange("Cleanup Action", "Data Cleanup GCVI"."Cleanup Action"::Delete);
                    end;
                  CleanupAction::Rename:
                    begin
                      "Data Cleanup GCVI".SetRange("Approve Rename", true);
                      "Data Cleanup GCVI".SetRange("Cleanup Action", "Data Cleanup GCVI"."Cleanup Action"::Rename);
                    end;
                end;

                case TableOption of
                  TableOption::Customer  : "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Customer);
                  TableOption::Vendor    : "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Vendor);
                  TableOption::Item      : "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Item);
                  TableOption::GLAccount : "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::"G/L Account");
                end;

                if NoFilter <> '' then begin
                  "Data Cleanup GCVI".SetFilter("No.", NoFilter);
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(CleanupAction;CleanupAction)
                {
                    Caption = 'Cleanup Action';
                }
                field(TableOption;TableOption)
                {
                    Caption = 'Table Option';
                }
                field(NoFilter;NoFilter)
                {
                    Caption = 'No. Filter';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        CleanupAction: Option Delete,Rename,Both;
        TableOption: Option All,Customer,Vendor,Item,GLAccount;
        [InDataSet]
        ProcessResult: Boolean;
        DataCleanupCVI2: Record "Data Cleanup GCVI";
        NoFilter: Text;
}

