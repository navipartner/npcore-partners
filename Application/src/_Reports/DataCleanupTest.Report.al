report 6060101 "NPR Data Cleanup Test"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Data Cleanup Test.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Data Cleanup Test';
    DataAccessIntent = ReadOnly;

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
            column(TestResult; TestResult)
            {
            }

            trigger OnAfterGetRecord()
            begin
                TestResult := DataCleanupCVILine.TestRun("Data Cleanup GCVI");
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
                    OptionCaption = 'Option All,Customer,Vendor,Item,GLAccount';
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
        DataCleanupCVILine: Codeunit "NPR Data Cleanup GCVI Line";
        [InDataSet]
        TestResult: Boolean;
        TableOption: Option All,Customer,Vendor,Item,GLAccount;
        CleanupAction: Option Delete,Rename,Both;
        NoFilter: Text;
}

