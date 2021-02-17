page 6014406 "NPR Register Card"
{
    UsageCategory = None;
    Caption = 'Cash Register Setup';
    RefreshOnActivate = true;
    SourceTable = "NPR Register";

    layout
    {
        area(content)
        {
            group(Register)
            {
                Caption = 'Register';
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Primary Payment Type"; Rec."Primary Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Payment Type field';
                }
                field("Return Payment Type"; Rec."Return Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Payment Type field';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group(Control6150716)
                {
                    ShowCaption = false;
                    field("End of Day Balancing"; '')
                    {
                        ApplicationArea = All;
                        Caption = 'End of Day Balancing';
                        ShowCaption = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the value of the End of Day Balancing field';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("User Setup")
                {
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                    RunPageLink = "NPR Backoffice Register No." = FIELD("Register No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the User Setup action';
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                action("Default Dimensions")
                {
                    Caption = 'Dimensions';
                    Image = DefaultDimension;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        Rec.DimsAreDiscontinuedOnRegister();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FieldDisplay1 := false;
        FieldDisplay2 := false;
    end;

    trigger OnOpenPage()
    begin
        FieldDisplayMetode := false;
        FieldDisplayPort := false;
        FieldDisplayTxtPath := false;
    end;

    var
        Text10600007: Label 'Saldo Inicial';
        [InDataSet]
        FieldDisplay1: Boolean;
        [InDataSet]
        FieldDisplay2: Boolean;
        [InDataSet]
        FieldDisplayMetode: Boolean;
        [InDataSet]
        FieldDisplayPort: Boolean;
        [InDataSet]
        FieldDisplayTxtPath: Boolean;
}

