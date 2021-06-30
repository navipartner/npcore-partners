page 6059894 "NPR Data Log Process. Entries"
{
    Editable = false;
    PageType = List;
    SourceTable = "NPR Data Log Processing Entry";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Inserted at"; Rec."Inserted at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inserted at field';
                }
                field("Subscriber Code"; Rec."Subscriber Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Code field';
                }
                field("Table Number"; Rec."Table Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Number field';
                }
                field("Data Log Entry No."; Rec."Data Log Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Log Entry No field';
                }
                field("Data Log Record Value"; Rec."Data Log Record Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Log Record Value field';
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message field';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorMessage());
                    end;
                }
                field("Processing Started at"; Rec."Processing Started at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Started at field';
                }
                field("Processing Completed at"; Rec."Processing Completed at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Completed at field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(DataLog)
            {
                Caption = 'Data Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Data Log Records";
                RunPageLink = "Entry No." = FIELD("Data Log Entry No."),
                              "Table ID" = FIELD("Table Number");
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Executes the Data Log action';
                ApplicationArea = All;
            }
        }
    }
}