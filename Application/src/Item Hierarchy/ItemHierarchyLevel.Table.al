table 6151051 "NPR Item Hierarchy Level"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj

    Caption = 'Item Hierarchy Level';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Hierarchy Code"; Code[20])
        {
            Caption = 'Hierarchy Setup ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Hierarchy"."Hierarchy Code";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // ItemHrchyMgt.GetLinkLevel(Rec,HrchyLevelSetup);
                // IF (HrchyLevelSetup."Hierarchy Setup ID" <> '') AND (Description = '') THEN BEGIN
                //  Description := HrchyLevelSetup.Description;
                //  "Link Table No." := HrchyLevelSetup."Link Table No.";
                //  "Link Table Name" := HrchyLevelSetup."Link Table Name";
                //  "Primary Field No." := HrchyLevelSetup."Primary Field No.";
                //  "Primary Field Name" := HrchyLevelSetup."Primary Field Name";
                //  Code := HrchyLevelSetup.Code;
                //  "Description Field No." := HrchyLevelSetup."Description Field No.";
                //  "Description Field Name" := HrchyLevelSetup."Description Field Name";
                //  "Level Link Field No." := HrchyLevelSetup."Level Link Field No.";
                //  "Level Link Field Name" := HrchyLevelSetup."Level Link Field Name";
                //  "Level Link Filter" := HrchyLevelSetup."Level Link Filter";
                //  "Ext. Filter Field No." := "Ext. Filter Field No.";
                //  "Ext. Filter Field Name" := "Ext. Filter Field Name";
                //  "Ext. Filter" := HrchyLevelSetup."Ext. Filter";
                //  "Item Field No." := HrchyLevelSetup."Item Field No.";
                //  "Item Field Name" := HrchyLevelSetup."Item Field Name";
                //  "Switch To Item" := HrchyLevelSetup."Switch To Item";
                //  "Calc. Field1 No." := HrchyLevelSetup."Calc. Field1 No.";
                //  "Calc. Field1 Name" := HrchyLevelSetup."Calc. Field1 Name";
                //  "Reverse Sign Field1" := HrchyLevelSetup."Reverse Sign Field1";
                //  "Calc. Field2 No." := HrchyLevelSetup."Calc. Field2 No.";
                //  "Calc. Field2 Name" := HrchyLevelSetup."Calc. Field2 Name";
                //  "Reverse Sign Field2" := HrchyLevelSetup."Reverse Sign Field2";
                //  "Calc. Field3 No." := HrchyLevelSetup."Calc. Field3 No.";
                //  "Calc. Field3 Name" := HrchyLevelSetup."Calc. Field3 Name";
                //  "Reverse Sign Field3" := HrchyLevelSetup."Reverse Sign Field3";
                //  "Calc. Field4 No." := HrchyLevelSetup."Calc. Field4 No.";
                //  "Calc. Field4 Name" := HrchyLevelSetup."Calc. Field4 Name";
                //  "Reverse Sign Field4" := HrchyLevelSetup."Reverse Sign Field4";
                //  "Calc. Field5 No." := HrchyLevelSetup."Calc. Field5 No.";
                //  "Calc. Field5 Name" := HrchyLevelSetup."Calc. Field5 Name";
                //  "Reverse Sign Field5" := HrchyLevelSetup."Reverse Sign Field5";
                //  "Location Filter Field No." := HrchyLevelSetup."Location Filter Field No.";
                //  "Location Filter Field Name" := HrchyLevelSetup."Location Filter Field Name";
                //  "Date Filter Field No." := HrchyLevelSetup."Date Filter Field No.";
                //  "Date Filter Field Name" := HrchyLevelSetup."Date Filter Field Name";
                //  "Global Dim 2 Filter Field No." := HrchyLevelSetup."Global Dim 2 Filter Field No.";
                //  "Global Dim 2 Filter Field Name" := HrchyLevelSetup."Global Dim 2 Filter Field Name";
                // END;
            end;
        }
        field(9; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Link Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnValidate()
            var
                "Object": Record "Object";
                AllObj: Record AllObjWithCaption;
            begin
                if "Table No." <> 0 then begin
                    //-NPR5.46 [322752]
                    //  IF Object.GET(Object.Type::Table,COMPANYNAME,"Table No.") THEN
                    //  Rec."Link Table Name" := COPYSTR(Object.Caption,1,50);
                    //  IF Description = '' THEN
                    //    Description := COPYSTR(Object.Caption,1,30);

                    if AllObj.Get(AllObj."Object Type"::Table, "Table No.") then
                        Rec."Link Table Name" := CopyStr(AllObj."Object Caption", 1, 50);
                    if Description = '' then
                        Description := CopyStr(AllObj."Object Caption", 1, 30);
                    //-NPR5.46 [322752]
                end;
            end;
        }
        field(21; "Primary Field No."; Integer)
        {
            Caption = 'Primary Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnValidate()
            begin
                TestField("Table No.");
                //
                // IF "Primary Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Primary Field No.");
                //  "Primary Field Name" := Field."Field Caption";
                // END ELSE BEGIN
                //  "Primary Field Name" := '';
                // END;
                // Code := '';
            end;
        }
        field(22; "Description Field No."; Integer)
        {
            Caption = 'Description Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnValidate()
            begin
                TestField("Table No.");
                //
                // IF "Description Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Description Field No.");
                //  "Description Field Name" := Field."Field Caption";
                // END ELSE
                //  "Description Field Name" := '';
            end;
        }
        field(23; "Level Link Table No."; Integer)
        {
            Caption = 'Level Link Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(24; "Level Link Field No."; Integer)
        {
            Caption = 'Level Link Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Level Link Table No."));

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                //
                // IF "Level Link Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Level Link Field No.");
                //  "Level Link Field Name" := Field."Field Caption";
                // END ELSE
                //  "Level Link Field Name" := '';
                //
                // "Level Link Filter" := '';
            end;
        }
        field(25; "Level Link Filter"; Text[80])
        {
            Caption = 'Level Link Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                // TESTFIELD("Level Link Field No.");
            end;
        }
        field(26; "Second Level Link Table No."; Integer)
        {
            Caption = 'Second Level Link Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(27; "Second Level Link Field No."; Integer)
        {
            Caption = 'Second Level Link Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Second Level Link Table No."));

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                //
                // IF "Level Link Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Level Link Field No.");
                //  "Level Link Field Name" := Field."Field Caption";
                // END ELSE
                //  "Level Link Field Name" := '';
                //
                // "Level Link Filter" := '';
            end;
        }
        field(28; "Second Level Link Filter"; Text[80])
        {
            Caption = 'Second Level Link Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                // TESTFIELD("Level Link Field No.");
            end;
        }
        field(29; "Second Level Primary Field No."; Integer)
        {
            Caption = 'Second Level Primary Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                //
                // IF "Primary Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Primary Field No.");
                //  "Primary Field Name" := Field."Field Caption";
                // END ELSE BEGIN
                //  "Primary Field Name" := '';
                // END;
                // Code := '';
            end;
        }
        field(30; "Ext. Filter"; Text[80])
        {
            Caption = 'Ext. Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                // TESTFIELD("Ext. Filter Field No.");
            end;
        }
        field(31; "Ext. Filter Field No."; Integer)
        {
            Caption = 'Ext. Filter Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                //
                // IF "Ext. Filter Field No." <> 0 THEN BEGIN
                //  Field.GET("Link Table No.","Ext. Filter Field No.");
                //  "Ext. Filter Field Name" := Field."Field Caption";
                // END ELSE
                //  "Ext. Filter Field Name" := '';
                //
                // "Ext. Filter" := '';
            end;
        }
        field(32; "Link Table Name"; Text[250])
        {
            Caption = 'Link Table Name';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(40; "Item Field No."; Integer)
        {
            Caption = 'Item Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = CONST(27));

            trigger OnValidate()
            begin
                // TESTFIELD("Link Table No.");
                //
                // IF "Item Field No." <> 0 THEN BEGIN
                //  Field.GET(27,"Item Field No.");
                //  "Item Field Name" := Field."Field Caption";
                // END ELSE
                //  "Item Field Name" := '';
                //
                // "Switch To Item" := FALSE;
            end;
        }
    }

    keys
    {
        key(Key1; "Hierarchy Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
    begin
        ItemHierarchyLine.SetRange("Item Hierarchy Code", "Hierarchy Code");
        ItemHierarchyLine.SetRange("Item Hierarchy Level", Level);
        ItemHierarchyLine.DeleteAll(true);
    end;
}

