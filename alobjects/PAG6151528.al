page 6151528 "Nc Collector List"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector List';
    CardPageID = "Nc Collector Card";
    Editable = false;
    PageType = List;
    SourceTable = "Nc Collector";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Collection Lines")
            {
                Caption = 'Collection Lines';
                Image = XMLFile;
                RunObject = Page "Nc Collection Lines";
                RunPageLink = "Collector Code" = FIELD(Code);
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);
            }
        }
    }
}

