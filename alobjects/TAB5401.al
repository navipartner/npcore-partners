tableextension 50043 tableextension50043 extends "Item Variant" 
{
    // NPR5.29/TJ  /20170119 CASE 263917 Moved function GetFromVariety to codeunit 6059972
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018
    fields
    {
        field(6059970;"Variety 1";Code[10])
        {
            Caption = 'Variety 1';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059971;"Variety 1 Table";Code[40])
        {
            Caption = 'Variety 1 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type=FIELD("Variety 1"));
        }
        field(6059972;"Variety 1 Value";Code[20])
        {
            Caption = 'Variety 1 Value';
            Description = 'VRT1.00';
            TableRelation = "Variety Value".Value WHERE (Type=FIELD("Variety 1"),
                                                         Table=FIELD("Variety 1 Table"));
        }
        field(6059973;"Variety 2";Code[10])
        {
            Caption = 'Variety 2';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059974;"Variety 2 Table";Code[40])
        {
            Caption = 'Variety 2 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type=FIELD("Variety 2"));
        }
        field(6059975;"Variety 2 Value";Code[20])
        {
            Caption = 'Variety 2 Value';
            Description = 'VRT1.00';
            TableRelation = "Variety Value".Value WHERE (Type=FIELD("Variety 2"),
                                                         Table=FIELD("Variety 2 Table"));
        }
        field(6059976;"Variety 3";Code[10])
        {
            Caption = 'Variety 3';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059977;"Variety 3 Table";Code[40])
        {
            Caption = 'Variety 3 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type=FIELD("Variety 3"));
        }
        field(6059978;"Variety 3 Value";Code[20])
        {
            Caption = 'Variety 3 Value';
            Description = 'VRT1.00';
            TableRelation = "Variety Value".Value WHERE (Type=FIELD("Variety 3"),
                                                         Table=FIELD("Variety 3 Table"));
        }
        field(6059979;"Variety 4";Code[10])
        {
            Caption = 'Variety 4';
            Description = 'VRT1.00';
            TableRelation = Variety;
        }
        field(6059980;"Variety 4 Table";Code[40])
        {
            Caption = 'Variety 4 Table';
            Description = 'VRT1.00';
            TableRelation = "Variety Table".Code WHERE (Type=FIELD("Variety 4"));
        }
        field(6059981;"Variety 4 Value";Code[20])
        {
            Caption = 'Variety 4 Value';
            Description = 'VRT1.00';
            TableRelation = "Variety Value".Value WHERE (Type=FIELD("Variety 4"),
                                                         Table=FIELD("Variety 4 Table"));
        }
        field(6059982;Blocked;Boolean)
        {
            Caption = 'Blocked';
            Description = 'VRT1.00';
        }
    }
    keys
    {
        key(Key1;"Item No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value")
        {
        }
    }
}

