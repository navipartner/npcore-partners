table 6151521 "Nc Trigger Setup"
{
    // NC2.01/BR /20160809  CASE 247479 NaviConnect: Object created

    Caption = 'Nc Trigger Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Task Template Name";Code[10])
        {
            Caption = 'Task Template Name';
            TableRelation = "Task Template";
        }
        field(20;"Task Batch Name";Code[10])
        {
            Caption = 'Task Batch Name';
            TableRelation = "Task Batch".Name WHERE ("Journal Template Name"=FIELD("Task Template Name"));
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

