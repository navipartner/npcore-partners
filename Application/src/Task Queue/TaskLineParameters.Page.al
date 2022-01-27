page 6059909 "NPR Task Line Parameters"
{
    Extensible = False;
    // TQ1.17/JDH/20141027 CASE 187044 Format of Value Field Updated
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Dont show fields that is meant for data type validation only

    Caption = 'Task Line Parameters';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Task Line Parameters";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Code"; Rec."Field Code")
                {

                    ToolTip = 'Specifies the value of the Field Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Type"; Rec."Field Type")
                {

                    ToolTip = 'Specifies the value of the Field Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Text Sub Type"; Rec."Text Sub Type")
                {

                    ToolTip = 'Specifies the value of the Text Sub Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Text Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Value"; Rec."Date Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Value"; Rec."Time Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Time Value field';
                    ApplicationArea = NPRRetail;
                }
                field("DateTime Value"; Rec."DateTime Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the DateTime Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Integer Value"; Rec."Integer Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Integer Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Decimal Value"; Rec."Decimal Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Decimal Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Boolean Value"; Rec."Boolean Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Boolean Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //-TQ1.17
        Rec.FormatValueField();
        //+TQ1.17
    end;
}

