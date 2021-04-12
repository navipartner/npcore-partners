page 6059909 "NPR Task Line Parameters"
{
    // TQ1.17/JDH/20141027 CASE 187044 Format of Value Field Updated
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Dont show fields that is meant for data type validation only

    Caption = 'Task Line Parameters';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Task Line Parameters";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Line No. field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Field Code"; Rec."Field Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Code field';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Type field';
                }
                field("Text Sub Type"; Rec."Text Sub Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Sub Type field';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Value field';
                }
                field("Date Value"; Rec."Date Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Value field';
                }
                field("Time Value"; Rec."Time Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Time Value field';
                }
                field("DateTime Value"; Rec."DateTime Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the DateTime Value field';
                }
                field("Integer Value"; Rec."Integer Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Integer Value field';
                }
                field("Decimal Value"; Rec."Decimal Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Decimal Value field';
                }
                field("Boolean Value"; Rec."Boolean Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Boolean Value field';
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
        Rec.FormatValueField;
        //+TQ1.17
    end;
}

