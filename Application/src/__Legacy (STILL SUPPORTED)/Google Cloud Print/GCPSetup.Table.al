table 6014583 "NPR GCP Setup"
{
    // NPR5.26/MMV /20160826 CASE 246209 Created table.
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions

    Caption = 'Google Cloud Print Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Printer ID"; Text[50])
        {
            Caption = 'Printer ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                GCPMgt: Codeunit "NPR GCP Mgt.";
                ID: Text;
            begin
                if GCPMgt.LookupPrinters(ID) then
                    "Printer ID" := ID;
            end;
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Report,Codeunit';
            OptionMembers = "Report","Codeunit";
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            TableRelation = IF ("Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
        field(4; "Cloud Job Ticket"; BLOB)
        {
            Caption = 'Cloud Job Ticket';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Printer ID", "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

