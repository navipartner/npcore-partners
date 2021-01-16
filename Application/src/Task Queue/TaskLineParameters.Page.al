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
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                }
                field("Journal Line No."; "Journal Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Journal Line No. field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Field Code"; "Field Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Code field';
                }
                field("Field Type"; "Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Type field';
                }
                field("Text Sub Type"; "Text Sub Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Sub Type field';
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Text Value field';
                }
                field("Date Value"; "Date Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date Value field';
                }
                field("Time Value"; "Time Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Time Value field';
                }
                field("DateTime Value"; "DateTime Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the DateTime Value field';
                }
                field("Integer Value"; "Integer Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Integer Value field';
                }
                field("Decimal Value"; "Decimal Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Decimal Value field';
                }
                field("Boolean Value"; "Boolean Value")
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
        FormatValueField;
        //+TQ1.17
    end;
}

