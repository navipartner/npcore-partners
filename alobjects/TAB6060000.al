table 6060000 "GIM - Document Type"
{
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field

    Caption = 'GIM - Document Type';
    LookupPageID = "GIM - Document Types";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(10;"Raw Data Reader";Integer)
        {
            Caption = 'Raw Data Reader';
        }
        field(20;"Data Type Validator";Integer)
        {
            Caption = 'Data Type Validator';
        }
        field(30;"Data Mapper";Integer)
        {
            Caption = 'Data Mapper';
        }
        field(40;"Data Verification";Integer)
        {
            Caption = 'Data Verification';
        }
        field(50;"Data Creation";Integer)
        {
            Caption = 'Data Creation';
        }
        field(60;"Default Notification Method";Option)
        {
            Caption = 'Default Notification Method';
            OptionCaption = ' ,File,E-mail,Gambit';
            OptionMembers = " ",File,"E-mail",Gambit;
        }
        field(61;"Recipient E-mail";Text[250])
        {
            Caption = 'Recipient E-mail';
        }
        field(70;"FTP Search Folder";Text[250])
        {
            Caption = 'FTP Search Folder';
        }
        field(71;"FTP File Action After Read";Option)
        {
            Caption = 'FTP File Action After Read';
            OptionCaption = 'Archive,Delete';
            OptionMembers = Archive,Delete;
        }
        field(72;"FTP Archive Folder";Text[250])
        {
            Caption = 'FTP Archive Folder';
        }
        field(73;"FTP Local Folder";Text[250])
        {
            Caption = 'FTP Local Folder';
        }
        field(74;"FTP Host Name";Text[250])
        {
            Caption = 'FTP Host Name';
        }
        field(75;"FTP Port";Integer)
        {
            Caption = 'FTP Port';
        }
        field(76;"FTP Username";Text[100])
        {
            Caption = 'FTP Username';
        }
        field(77;"FTP Password";Text[100])
        {
            Caption = 'FTP Password';
        }
        field(78;"FTP Active";Boolean)
        {
            Caption = 'FTP Active';
        }
        field(90;"Base Version No.";Integer)
        {
            CalcFormula = Lookup("GIM - Document Type Version"."Version No." WHERE (Code=FIELD(Code),
                                                                                    "Sender ID"=FIELD("Sender ID"),
                                                                                    Base=CONST(true)));
            Caption = 'Base Version No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"LFU Folder Active";Boolean)
        {
            Caption = 'LFU Folder Active';
        }
        field(101;"LFU Search Folder";Text[250])
        {
            Caption = 'LFU Search Folder';
        }
        field(102;"LFU File Action After Read";Option)
        {
            Caption = 'LFU File Action After Read';
            OptionCaption = 'Archive,Delete';
            OptionMembers = Archive,Delete;
        }
        field(103;"LFU Archive Folder";Text[250])
        {
            Caption = 'LFU Archive Folder';
        }
        field(110;"Preview Type";Option)
        {
            Caption = 'Preview Type';
            OptionCaption = ' ,Item,Sales Order,Purchase Order';
            OptionMembers = " ",Item,"Sales Order","Purchase Order";
        }
        field(111;"Preview Provided Data Only";Boolean)
        {
            Caption = 'Preview Provided Data Only';
        }
        field(120;"WS Active";Boolean)
        {
            Caption = 'WS Active';
        }
        field(130;"Data Format Code";Code[20])
        {
            Caption = 'Data Format Code';
            TableRelation = "GIM - Data Format".Code;
        }
    }

    keys
    {
        key(Key1;"Code","Sender ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        "Object": Record "Object";
        AllObj: Record AllObj;

    procedure LookupCodeunit(FieldNoHere: Integer)
    var
        Objects: Page Objects;
        AllObjs: Page "All Objects";
    begin
        //-NPR5.46[322752]
        // Object.SETRANGE(Type,Object.Type::Codeunit);
        // Objects.SETTABLEVIEW(Object);
        // Objects.EDITABLE(FALSE);
        // Objects.LOOKUPMODE(TRUE);
        // IF Objects.RUNMODAL = ACTION::LookupOK THEN BEGIN
        //  Objects.GETRECORD(Object);
        //  CASE FieldNoHere OF
        //    FIELDNO("Raw Data Reader"):
        //      VALIDATE("Raw Data Reader",Object.ID);
        //    FIELDNO("Data Type Validator"):
        //      VALIDATE("Data Type Validator",Object.ID);
        //    FIELDNO("Data Mapper"):
        //      VALIDATE("Data Mapper",Object.ID);
        //    FIELDNO("Data Verification"):
        //      VALIDATE("Data Verification",Object.ID);
        //    FIELDNO("Data Creation"):
        //      VALIDATE("Data Creation",Object.ID);
        //  END;
        // END;

        AllObj.SetRange("Object Type",AllObj."Object Type"::Codeunit);
        AllObjs.SetTableView(AllObj);
        AllObjs.Editable(false);
        AllObjs.LookupMode(true);
        if AllObjs.RunModal = ACTION::LookupOK then begin
          AllObjs.GetRecord(AllObj);
          case FieldNoHere of
            FieldNo("Raw Data Reader"):
              Validate("Raw Data Reader",AllObj."Object ID");
            FieldNo("Data Type Validator"):
              Validate("Data Type Validator",AllObj."Object ID");
            FieldNo("Data Mapper"):
              Validate("Data Mapper",AllObj."Object ID");
            FieldNo("Data Verification"):
              Validate("Data Verification",AllObj."Object ID");
            FieldNo("Data Creation"):
              Validate("Data Creation",AllObj."Object ID");
          end;
        end;
        //+NPR5.46[322752]
    end;
}

