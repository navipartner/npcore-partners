table 6014580 "Object Output Selection"
{
    // NPR4.15/MMV/20151002 CASE 223893 Added field 12 : Output Slave Path
    //                                  Added option 'Web' to field 10.
    // NPR5.22/MMV/20160317 CASE 228382 Added option 'E-mail', 'Google Print' to field 10.
    //                                  Renamed option 'Web' to 'Epson Web'.
    // NPR5.26/MMV /20160826 CASE 246209 Added lookup on GCP printers.
    // NPR5.29/MMV /20161208 CASE 260621 Fixed messy lookup code.
    // NPR5.29/MMV /20161220 CASE 241549 Renamed field 8
    // NPR5.29/MMV /20161018 CASE 253590 Added new option 'HTTP' in field 10.
    // NPR5.32/MMV /20170324 CASE 253590 Added new option 'Bluetooth' in field 10.
    //                                   Removed field 12.

    Caption = 'Object Output Selection';

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.ValidateUserID("User ID");
            end;
        }
        field(2;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Codeunit,Report,XMLPort';
            OptionMembers = "Codeunit","Report","XMLPort";
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type"=CONST(Codeunit)) AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit))
                            ELSE IF ("Object Type"=CONST(Report)) AllObj."Object ID" WHERE ("Object Type"=CONST(Report))
                            ELSE IF ("Object Type"=CONST(XMLPort)) AllObj."Object ID" WHERE ("Object Type"=CONST(XMLport));

            trigger OnValidate()
            begin
                GetObjectName;
            end;
        }
        field(5;"Object Name";Text[80])
        {
            Caption = 'Object Name';
        }
        field(8;"Print Template";Code[20])
        {
            Caption = 'Print Template';
            TableRelation = "RP Template Header".Code;
        }
        field(10;"Output Type";Option)
        {
            Caption = 'Output Type';
            OptionCaption = 'Printer Name,File,Epson Web,E-mail,Google Print,HTTP,Bluetooth';
            OptionMembers = "Printer Name",File,"Epson Web","E-mail","Google Print",HTTP,Bluetooth;
        }
        field(11;"Output Path";Text[250])
        {
            Caption = 'Output Path';
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            var
                Printer: Record Printer;
                GCPMgt: Codeunit "GCP Mgt.";
                ID: Text;
            begin
                case "Output Type" of
                  "Output Type"::"Printer Name" :
                    begin
                      if PAGE.RunModal(PAGE::Printers, Printer) = ACTION::LookupOK then
                        "Output Path" := Printer.ID;
                    end;

                  "Output Type"::"Google Print" :
                    begin
                      if GCPMgt.LookupPrinters(ID) then
                        "Output Path" := ID;
                    end;
                end;
            end;
        }
    }

    keys
    {
        key(Key1;"User ID","Object Type","Object ID","Print Template")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        GetObjectName;
    end;

    trigger OnModify()
    begin
        GetObjectName;
    end;

    procedure GetObjectName()
    var
        AllObj: Record AllObj;
    begin
        case "Object Type" of
          "Object Type"::Codeunit:
            AllObj.SetRange("Object Type",AllObj."Object Type"::Codeunit);
          "Object Type"::Report:
            AllObj.SetRange("Object Type",AllObj."Object Type"::Report);
          "Object Type"::XMLPort:
            AllObj.SetRange("Object Type",AllObj."Object Type"::XMLport);
        end;

        AllObj.SetRange("Object ID","Object ID");

        if AllObj.FindFirst then
          "Object Name" := AllObj."Object Name";
    end;
}

