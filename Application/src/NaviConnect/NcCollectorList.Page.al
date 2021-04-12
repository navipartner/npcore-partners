page 6151528 "NPR Nc Collector List"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collector List';
    CardPageID = "NPR Nc Collector Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collector";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
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
                RunObject = Page "NPR Nc Collection Lines";
                RunPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Collection Lines action';
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "NPR Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Collections action';
            }
        }
    }
}

