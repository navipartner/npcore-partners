report 6060102 "NPR Data Cleanup Process"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Data Cleanup Process.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Data Cleanup Process';
    dataset
    {
        dataitem("Data Cleanup GCVI"; "NPR Data Cleanup GCVI")
        {
            DataItemTableView = SORTING("Cleanup Action", Type, "No.") ORDER(Ascending) WHERE(IsProcessed = CONST(false), IsApproved = CONST(true), Retries = FILTER(< 10));
            column(CleanupAction_DataCleanupCVI; "Data Cleanup GCVI"."Cleanup Action")
            {
            }
            column(Type_DataCleanupCVI; "Data Cleanup GCVI".Type)
            {
            }
            column(No_DataCleanupCVI; "Data Cleanup GCVI"."No.")
            {
            }
            column(Status_DataCleanupCVI; "Data Cleanup GCVI".Status)
            {
            }
            column(Description_DataCleanupCVI; "Data Cleanup GCVI".Description)
            {
            }
            column(Retries_DataCleanupCVI; "Data Cleanup GCVI".Retries)
            {
            }
            column(ProcessResult; ProcessResult)
            {
            }

            trigger OnAfterGetRecord()
            var
                SuccessLbl: Label 'SUCCESS';
            begin

                DataCleanupCVI2.Get("Data Cleanup GCVI"."Cleanup Action", "Data Cleanup GCVI".Type, "Data Cleanup GCVI"."No.");

                if not CODEUNIT.Run(CODEUNIT::"NPR Data Cleanup GCVI Line", DataCleanupCVI2) then begin
# pragma warning disable AA0139
                    DataCleanupCVI2.Status := GetLastErrorText;
# pragma warning restore
                    DataCleanupCVI2.IsError := true;
                    ProcessResult := false;
                end else begin
                    DataCleanupCVI2.Status := SuccessLbl;
                    DataCleanupCVI2.IsDeleted := true;
                    DataCleanupCVI2.IsProcessed := true;
                    DataCleanupCVI2.Success := true;
                    ProcessResult := true;
                end;

                if (not ProcessResult) or (ProcessResult and ("Data Cleanup GCVI".Type = "Data Cleanup GCVI"."Cleanup Action"::Delete)) then begin
                    DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                    DataCleanupCVI2.Modify(true);
                    Commit();
                end else begin
                    DataCleanupCVI2.Get("Data Cleanup GCVI"."Cleanup Action", "Data Cleanup GCVI".Type, "Data Cleanup GCVI"."NewNo.");

                    DataCleanupCVI2.Status := SuccessLbl;
                    DataCleanupCVI2.IsDeleted := true;
                    DataCleanupCVI2.IsProcessed := true;
                    DataCleanupCVI2.Success := true;
                    ProcessResult := true;

                    DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                    DataCleanupCVI2.Modify(true);
                    Commit();
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
                    TableOption::Customer:
                        "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Customer);
                    TableOption::Vendor:
                        "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Vendor);
                    TableOption::Item:
                        "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::Item);
                    TableOption::GLAccount:
                        "Data Cleanup GCVI".SetRange(Type, "Data Cleanup GCVI".Type::"G/L Account");
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
                field("Cleanup Action"; CleanupAction)
                {

                    Caption = 'Cleanup Action';
                    OptionCaption = 'Delete,Rename,Both';
                    ToolTip = 'Specifies the value of the Cleanup Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Option"; TableOption)
                {

                    Caption = 'Table Option';
                    OptionCaption = 'All,Customer,Vendor,Item,GLAccount';
                    ToolTip = 'Specifies the value of the Table Option field';
                    ApplicationArea = NPRRetail;
                }
                field("No Filter"; NoFilter)
                {

                    Caption = 'No. Filter';
                    ToolTip = 'Specifies the value of the No. Filter field';
                    ApplicationArea = NPRRetail;
                }
            }
        }

    }


    var
        DataCleanupCVI2: Record "NPR Data Cleanup GCVI";
        [InDataSet]
        ProcessResult: Boolean;
        TableOption: Option All,Customer,Vendor,Item,GLAccount;
        CleanupAction: Option Delete,Rename,Both;
        NoFilter: Text;
}

