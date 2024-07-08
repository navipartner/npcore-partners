page 6150797 "NPR Digital Receipt Setup"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'Digital Receipt Setup';
    PageType = Card;
    SourceTable = "NPR Digital Receipt Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/digital_receipts/';


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'Credentials';
                group(Credentials)
                {
                    ShowCaption = false;
                    field("Api Key"; Rec."Api Key")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Represents the unique identifier used to connect to the Fiskaly API.';
                        StyleExpr = StyleExprTxt;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    field("Api Secret"; Rec."Api Secret")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Denotes the confidential authentication key paired with your API Key for secure communication with the Fiskaly API.';
                        ExtendedDatatype = Masked;
                        StyleExpr = StyleExprTxt;

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                }
                group(Test)
                {
                    ShowCaption = false;
                    field("Credentials Test Success"; Rec."Credentials Test Success")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Indicates the outcome of the test request. Displays true value if the credentials test was successful; otherwise, shows false.';
                        StyleExpr = StyleExprTxt;
                    }
                    field("Last Success Test Time"; Rec."Last Credentials Test DateTime")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Timestamp indicating the date and time of the last credentials test. Provides insights into the recent status of your Fiskaly API connection.';
                        StyleExpr = StyleExprTxt;
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(TestAPICredentials)
            {
                Caption = 'Test API Credentials';
                Image = ServiceSetup;
                ToolTip = 'Initiates a test request to validate the provided API Key and API Secret. Use this action to ensure the accuracy and effectiveness of your Fiskaly API credentials. The results will be reflected in the ''Credentials Test Success'' field, along with the timestamp in ''Last Credentials Test Datetime''.';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    APICredentialsTest();
                end;
            }
        }
        area(Navigation)
        {
            action("POS Receipt Profiles")
            {
                Caption = 'POS Receipt Profiles';
                ToolTip = 'Explore and customize profiles for POS receipts to match your business preferences and requirements.';
                Image = SetupList;
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR POS Receipt Profiles";
            }

            action("POS Digital Receipt Entries")
            {
                Caption = 'POS Digital Receipt Entries';
                ToolTip = 'View and manage digital receipt entries for your POS transactions.';
                Image = ReceiptLines;
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR POSSaleDigitalRcptEntries";
            }
        }
    }

    var
        StyleExprTxt: Text;

    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Credentials Test Success" then
            StyleExprTxt := 'favorable'
        else
            StyleExprTxt := 'standard';
    end;

    local procedure APICredentialsTest()
    var
        FiskalyAPI: Codeunit "NPR Fiskaly API";
        ValidCredentialsLbl: Label 'API credentials are valid.';
    begin
        ClearLastError();
        Rec."Last Credentials Test DateTime" := CurrentDateTime();
        Rec."Credentials Test Success" := FiskalyAPI.TryTestAPICredentials(Rec."Api Key", Rec."Api Secret");

        if Rec."Credentials Test Success" and GuiAllowed then
            Message(ValidCredentialsLbl)
        else begin
            Rec.Modify();
            Commit();
            Error(GetLastErrorText());
        end;
    end;
}
