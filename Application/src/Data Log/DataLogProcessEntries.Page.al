page 6059894 "NPR Data Log Process. Entries"
{
    Extensible = False;
    Editable = false;
    PageType = List;
    SourceTable = "NPR Data Log Processing Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;
    Caption = 'Data Log Process. Entries';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Inserted at"; Rec."Inserted at")
                {

                    ToolTip = 'Specifies the value of the Inserted at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Subscriber Code"; Rec."Subscriber Code")
                {

                    ToolTip = 'Specifies the value of the Subscriber Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Number"; Rec."Table Number")
                {

                    ToolTip = 'Specifies the value of the Table Number field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Data Log Entry No."; Rec."Data Log Entry No.")
                {

                    ToolTip = 'Specifies the value of the Data Log Entry No field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Data Log Record Value"; Rec."Data Log Record Value")
                {

                    ToolTip = 'Specifies the value of the Data Log Record Value field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {
                    Caption = 'Error Message';

                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorMessage());
                    end;
                }
                field("Processing Started at"; Rec."Processing Started at")
                {

                    ToolTip = 'Specifies the value of the Processing Started at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Processing Completed at"; Rec."Processing Completed at")
                {

                    ToolTip = 'Specifies the value of the Processing Completed at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRNaviConnect;
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
                ApplicationArea = NPRNaviConnect;

            }
        }
    }
}
