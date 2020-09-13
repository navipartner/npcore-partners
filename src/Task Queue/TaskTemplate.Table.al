table 6059900 "NPR Task Template"
{
    // TQ1.11/JDH/20140905 CASE 190421 BullZip PDF Printer Added
    // TQ1.16/JDH/20140916 CASE 179044 Alignment to 2013
    // TQ1.16/JDH/20140923 CASE 179044 Added SMTP mail support
    // TQ1.27/JDH/20150701 CASE 217903 Deleted unused Variables and fields
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.33/BHR /20180824  CASE 322752 Replace record Object to Allobj -fields 5,6

    Caption = 'Task Template';
    LookupPageID = "NPR Task Template";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Test Report ID"; Integer)
        {
            Caption = 'Test Report ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
        field(6; "Page ID"; Integer)
        {
            Caption = 'Form ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Page));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Page ID" = 0 then
                    Validate(Type);
            end;
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'General,NaviPartner';
            OptionMembers = General,NaviPartner;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NASGroup: Record "NPR Task Worker Group";
            begin
                //"Test Report ID" := REPORT::"General Journal - Test";
                //"Posting Report ID" := REPORT::"G/L Register";
                case Type of
                    Type::General:
                        begin
                            "Page ID" := PAGE::"NPR Task Journal";
                            "Mail Program" := "Mail Program"::JMail;
                            case NASGroup.Count of
                                0:
                                    begin
                                        NASGroup.InsertDefault;
                                        NASGroup.FindFirst;
                                        "Task Worker Group" := NASGroup.Code;
                                    end;
                                1:
                                    begin
                                        NASGroup.FindFirst;
                                        "Task Worker Group" := NASGroup.Code;
                                    end;
                            end;
                        end;
                    Type::NaviPartner:
                        begin
                            //"Page ID" :=  PAGE::Page6059910;
                            "Mail Program" := "Mail Program"::JMail;
                            case NASGroup.Count of
                                0:
                                    begin
                                        NASGroup.InsertDefault;
                                        NASGroup.FindFirst;
                                        "Task Worker Group" := NASGroup.Code;
                                    end;
                                1:
                                    begin
                                        NASGroup.FindFirst;
                                        "Task Worker Group" := NASGroup.Code;
                                    end;
                            end;
                        end;

                end;
            end;
        }
        field(15; "Test Report Name"; Text[80])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Test Report ID")));
            Caption = 'Test Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Page Name"; Text[80])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Form Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
            DataClassification = CustomerContent;
        }
        field(30; "Mail Program"; Option)
        {
            Caption = 'Mail Program';
            InitValue = SMTPMail;
            OptionCaption = ' ,J-Mail,SMTP-Mail';
            OptionMembers = " ",JMail,SMTPMail;
            DataClassification = CustomerContent;
        }
        field(31; "Mail From Address"; Text[80])
        {
            Caption = 'Mail From Address';
            DataClassification = CustomerContent;
        }
        field(32; "Mail From Name"; Text[80])
        {
            Caption = 'Mail From Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Description, Type)
        {
        }
    }

    trigger OnDelete()
    begin
        TaskLine.SetRange("Journal Template Name", Name);
        TaskLine.DeleteAll(true);
        TaskBatch.SetRange("Journal Template Name", Name);
        TaskBatch.DeleteAll;
    end;

    trigger OnInsert()
    begin
        Validate("Page ID");
    end;

    var
        TaskBatch: Record "NPR Task Batch";
        TaskLine: Record "NPR Task Line";
}

