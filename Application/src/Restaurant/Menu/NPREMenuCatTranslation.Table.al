#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151274 "NPR NPRE Menu Cat. Translation"
{
    Access = Internal;
    Extensible = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPR NPRE Restaurant".Code;
        }
        field(2; "Menu Code"; Code[20])
        {
            Caption = 'Menu Code';
            TableRelation = "NPR NPRE Menu".Code where("Restaurant Code" = field("Restaurant Code"));
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            TableRelation = "NPR NPRE Menu Category"."Category Code" where("Restaurant Code" = field("Restaurant Code"), "Menu Code" = field("Menu Code"));
        }
        field(4; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            NotBlank = true;
        }
        field(10; Title; Text[50])
        {
            Caption = 'Title';
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(pk; "Restaurant Code", "Menu Code", "Category Code", "Language Code")
        {
            Clustered = true;
        }
    }
}
#endif
