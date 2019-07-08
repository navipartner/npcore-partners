page 6059909 "Task Line Parameters"
{
    // TQ1.17/JDH/20141027 CASE 187044 Format of Value Field Updated
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Dont show fields that is meant for data type validation only

    Caption = 'Task Line Parameters';
    PageType = List;
    SourceTable = "Task Line Parameters";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name";"Journal Template Name")
                {
                    Visible = false;
                }
                field("Journal Batch Name";"Journal Batch Name")
                {
                    Visible = false;
                }
                field("Journal Line No.";"Journal Line No.")
                {
                    Visible = false;
                }
                field("Field No.";"Field No.")
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                }
                field("Field Code";"Field Code")
                {
                }
                field("Field Type";"Field Type")
                {
                }
                field("Text Sub Type";"Text Sub Type")
                {
                }
                field(Value;Value)
                {
                }
                field("Date Value";"Date Value")
                {
                    Visible = false;
                }
                field("Time Value";"Time Value")
                {
                    Visible = false;
                }
                field("DateTime Value";"DateTime Value")
                {
                    Visible = false;
                }
                field("Integer Value";"Integer Value")
                {
                    Visible = false;
                }
                field("Decimal Value";"Decimal Value")
                {
                    Visible = false;
                }
                field("Boolean Value";"Boolean Value")
                {
                    Visible = false;
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

