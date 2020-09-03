table 6014554 "NPR Attribute ID"
{
    // NPR5.22.01/TSA/22-04-15 CASE 209946 - Entity and Shortcut Attributes
    // NPR5.22.01/TSA/20160601 CASE 242867 Handler for OnDelete, OnRename, added field 20
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes

    Caption = 'Attribute ID';
    DrillDownPageID = "NPR Attribute IDs";
    LookupPageID = "NPR Attribute IDs";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "NPR Attribute".Code;
        }
        field(10; "Shortcut Attribute ID"; Option)
        {
            Caption = 'Shortcut Attribute ID';
            OptionCaption = 'Not Assigned,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40';
            OptionMembers = NOT_ASSIGNED,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40";

            trigger OnValidate()
            begin
                CheckOverlappingID();
            end;
        }
        field(11; "Entity Attribute ID"; Option)
        {
            Caption = 'Entity Attribute ID';
            OptionCaption = 'Not Assigned,1,2';
            OptionMembers = NOT_ASSIGNED,"1","2";

            trigger OnValidate()
            begin
                CheckOverlappingID();
            end;
        }
        field(20; "Key Layout"; Option)
        {
            Caption = 'Key Layout';
            Description = 'NPR5.22.01';
            OptionCaption = 'Not Set,Master Data,Document,Document Line,Worksheet Line, Worksheet Subline';
            OptionMembers = NOT_SET,MASTERDATA,DOCUMENT,DOCUMENTLINE,WORKSHEETLINE,WORKSHEETSUBLINE;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Attribute Code")
        {
        }
        key(Key2; "Attribute Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 already occupies %2 %3.\Select a different value for%2.';

    procedure CheckOverlappingID()
    var
        AttributeID: Record "NPR Attribute ID";
    begin

        if ("Shortcut Attribute ID" > 0) then begin
            AttributeID.Reset();
            AttributeID.SetFilter("Table ID", '=%1', "Table ID");
            AttributeID.SetFilter("Attribute Code", '<>%1', "Attribute Code");
            AttributeID.SetFilter("Shortcut Attribute ID", '=%1', "Shortcut Attribute ID");
            if (AttributeID.FindFirst()) then
                Error(Text001,
                       AttributeID."Attribute Code", AttributeID.FieldCaption("Shortcut Attribute ID"), AttributeID."Shortcut Attribute ID");
        end;

        if ("Entity Attribute ID" > 0) then begin
            AttributeID.Reset();
            AttributeID.SetFilter("Table ID", '=%1', "Table ID");
            AttributeID.SetFilter("Attribute Code", '<>%1', "Attribute Code");
            AttributeID.SetFilter("Entity Attribute ID", '=%1', "Entity Attribute ID");
            if (AttributeID.FindFirst()) then
                Error(Text001,
                       AttributeID."Attribute Code", AttributeID.FieldCaption("Shortcut Attribute ID"), AttributeID."Shortcut Attribute ID");
        end;
    end;
}

