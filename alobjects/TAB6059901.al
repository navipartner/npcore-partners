table 6059901 "Task Batch"
{
    // TQ1.16/JDH /20140923  CASE 179044 Added SMTP mail support
    // TQ1.21/JDH /20141219  CASE 202183 Added field "Delete Log After"
    // TQ1.27/JDH /20150701  CASE 217903 Deleted unused Variables and fields
    // TQ1.28/MHA /20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101  CASE 242044 Setting the "delete log after" to 90 days
    // TQ1.32/MHA /20180319  CASE 308403 Updated Hardcoded Dates with DMY2DATE to be Culture neutral in SetupNewBatch()

    Caption = 'Task Batch';
    DataCaptionFields = Name,Description;
    LookupPageID = "Task Batch";

    fields
    {
        field(1;"Journal Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Task Template";
        }
        field(2;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(19;"Task Worker Group";Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "Task Worker Group";
        }
        field(21;"Template Type";Option)
        {
            CalcFormula = Lookup("Task Template".Type WHERE (Name=FIELD("Journal Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'General,NaviPartner';
            OptionMembers = General,NaviPartner;
        }
        field(30;"Mail Program";Option)
        {
            Caption = 'Mail Program';
            InitValue = SMTPMail;
            OptionCaption = ' ,J-Mail,SMTP-Mail';
            OptionMembers = " ",JMail,SMTPMail;
        }
        field(31;"Mail From Address";Text[80])
        {
            Caption = 'Mail From Address';
        }
        field(32;"Mail From Name";Text[80])
        {
            Caption = 'Mail From Name';
        }
        field(40;"Common Companies";Boolean)
        {
            Caption = 'Common Companies';

            trigger OnValidate()
            var
                TaskJnlMgt: Codeunit "Task Jnl. Management";
            begin
                if not "Common Companies" then
                  exit;

                TestField("Task Worker Group");
                TestField("Mail Program");
                TestField("Master Company");
                TaskJnlMgt.SetupCommonBatch(Rec);
            end;
        }
        field(41;"Master Company";Text[30])
        {
            Caption = 'Master Company';
            TableRelation = Company;

            trigger OnValidate()
            begin
                if "Master Company" = '' then
                  exit;

                TestField("Common Companies", false);
            end;
        }
        field(80;"Delete Log After";Duration)
        {
            Caption = 'Delete Log After';
        }
    }

    keys
    {
        key(Key1;"Journal Template Name",Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TaskLine.SetRange("Journal Template Name","Journal Template Name");
        TaskLine.SetRange("Journal Batch Name",Name);
        TaskLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        LockTable;
        TaskTemplate.Get("Journal Template Name");
    end;

    var
        TaskTemplate: Record "Task Template";
        TaskLine: Record "Task Line";
        Text002: Label 'Days';

    procedure SetupNewBatch()
    var
        Date1: DateTime;
        Date2: DateTime;
    begin
        TaskTemplate.Get("Journal Template Name");
        "Mail Program" := TaskTemplate."Mail Program";
        "Mail From Address" := TaskTemplate."Mail From Address";
        "Mail From Name" := TaskTemplate."Mail From Name";
        //-TQ1.09
        "Task Worker Group" := TaskTemplate."Task Worker Group";
        //+TQ1.09
        //-TQ1.21
        //-TQ1.29
        //EVALUATE("Delete Log After", '200 '+ Text002);
        //hack to have duration set correctly to 90 days - an integer will have an overflow, and other datatypes fails with a duration variable
        //-TQ1.32 [308403]
        //Date1:= CREATEDATETIME(010416D, 0T);
        //Date2 := CREATEDATETIME(300616D, 0T);
        Date1:= CreateDateTime(DMY2Date(1,4,2016), 0T);
        Date2 := CreateDateTime(DMY2Date(30,6,2016), 0T);
        //-TQ1.32 [308403]
        "Delete Log After" := Date2 - Date1;
        //+TQ1.29
        //+TQ1.21
    end;

    procedure ModifyLines(i: Integer)
    begin
        TaskLine.LockTable;
        TaskLine.SetRange("Journal Template Name","Journal Template Name");
        TaskLine.SetRange("Journal Batch Name",Name);
        if TaskLine.Find('-') then repeat
          case i of
          end;
          TaskLine.Modify(true);
        until TaskLine.Next = 0;
    end;
}

