table 6060082 "MCS Rec. Business Rule"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Rec. Business Rule';
    DrillDownPageID = "MCS Rec. Business Rules";
    LookupPageID = "MCS Rec. Business Rules";

    fields
    {
        field(10;"Model No.";Code[10])
        {
            Caption = 'Model No.';
            TableRelation = "MCS Recommendations Model";
        }
        field(20;"Rule No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Rule No.';
            Editable = false;
        }
        field(30;Active;Boolean)
        {
            Caption = 'Active';
        }
        field(40;"Rule Type";Option)
        {
            Caption = 'Rule Type';
            OptionCaption = 'Block,WhiteList,Upsale';
            OptionMembers = Block,WhiteList,Upsale;
        }
        field(50;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Attribute';
            OptionMembers = Item,Attribute;
        }
        field(60;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Item)) Item."No."
                            ELSE IF (Type=CONST(Attribute)) "NPR Attribute".Code;
        }
        field(70;"Block Seed Item No.";Code[20])
        {
            Caption = 'Block Seed Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                if "Block Seed Item No." <> '' then begin
                  TestField(Type,Type::Item);
                  TestField("Rule Type","Rule Type"::Block);
                end;
            end;
        }
        field(100;"Last Sent Date Time";DateTime)
        {
            Caption = 'Last Sent Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Model No.","Rule No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        if (Type <> Type::Item) or
           ("Rule Type" <> "Rule Type"::Block) then
          "Block Seed Item No." := '';
    end;
}

