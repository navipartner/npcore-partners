table 6014580 "NPR Object Output Selection"
{
    Caption = 'Object Output Selection';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Codeunit,Report,XMLPort';
            OptionMembers = "Codeunit","Report","XMLPort";
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = CONST(Report))
            ELSE
            IF ("Object Type" = CONST(XMLPort)) AllObj."Object ID" WHERE("Object Type" = CONST(XMLport));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetObjectName;
            end;
        }
        field(5; "Object Name"; Text[80])
        {
            Caption = 'Object Name';
            DataClassification = CustomerContent;
        }
        field(8; "Print Template"; Code[20])
        {
            Caption = 'Print Template';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(10; "Output Type"; Option)
        {
            Caption = 'Output Type';
            OptionCaption = 'Printer Name,File,Epson Web,E-mail,Google Print,HTTP,Bluetooth,PrintNode PDF,PrintNode Raw';
            OptionMembers = "Printer Name",File,"Epson Web","E-mail","Google Print",HTTP,Bluetooth,"PrintNode PDF","PrintNode Raw";
            DataClassification = CustomerContent;
        }
        field(11; "Output Path"; Text[250])
        {
            Caption = 'Output Path';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Printer: Record Printer;
                PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
                ID: Text;
            begin
                case "Output Type" of
                    "Output Type"::"Printer Name":
                        begin
                            if PAGE.RunModal(PAGE::Printers, Printer) = ACTION::LookupOK then
                                "Output Path" := Printer.ID;
                        end;
                    "Output Type"::"PrintNode PDF",
                    "Output Type"::"PrintNode Raw":
                        begin
                            if PrintNodeMgt.LookupPrinter(ID) then
                                "Output Path" := ID;
                        end;

                end;
            end;
        }
    }

    keys
    {
        key(Key1; "User ID", "Object Type", "Object ID", "Print Template")
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
                AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
            "Object Type"::Report:
                AllObj.SetRange("Object Type", AllObj."Object Type"::Report);
            "Object Type"::XMLPort:
                AllObj.SetRange("Object Type", AllObj."Object Type"::XMLport);
        end;

        AllObj.SetRange("Object ID", "Object ID");

        if AllObj.FindFirst then
            "Object Name" := AllObj."Object Name";
    end;
}

