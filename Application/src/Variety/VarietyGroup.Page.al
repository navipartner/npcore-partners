page 6059977 "NPR Variety Group"
{
    // NPR5.43/NPKNAV/20180629  CASE 317108 Transport NPR5.43 - 29 June 2018

    Caption = 'Variety Group';
    PageType = List;
    SourceTable = "NPR Variety Group";
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
                field("Cross Variety No."; Rec."Cross Variety No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross Variety No. field';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Variety 1"; Rec."Variety 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 field';
                }
                field("Variety 1 Table"; Rec."Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Table field';
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field';
                }
                field("Copy Naming Variety 1"; Rec."Copy Naming Variety 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy Naming Variety 1 field';
                }
                field("Variety 2"; Rec."Variety 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 field';
                }
                field("Variety 2 Table"; Rec."Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Table field';
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field';
                }
                field("Copy Naming Variety 2"; Rec."Copy Naming Variety 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy Naming Variety 2 field';
                }
                field("Variety 3"; Rec."Variety 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 3 field';
                }
                field("Variety 3 Table"; Rec."Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 3 Table field';
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field';
                }
                field("Copy Naming Variety 3"; Rec."Copy Naming Variety 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy Naming Variety 3 field';
                }
                field("Variety 4"; Rec."Variety 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 4 field';
                }
                field("Variety 4 Table"; Rec."Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 4 Table field';
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                }
                field("Copy Naming Variety 4"; Rec."Copy Naming Variety 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy Naming Variety 4 field';
                }
                field("Variant Code Part 1"; Rec."Variant Code Part 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 1 field';
                }
                field("Variant Code Part 1 Length"; Rec."Variant Code Part 1 Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 1 Length field';
                }
                field("Variant Code Seperator 1"; Rec."Variant Code Seperator 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Seperator 1 field';
                }
                field("Variant Code Part 2"; Rec."Variant Code Part 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 2 field';
                }
                field("Variant Code Part 2 Length"; Rec."Variant Code Part 2 Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 2 Length field';
                }
                field("Variant Code Seperator 2"; Rec."Variant Code Seperator 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Seperator 2 field';
                }
                field("Variant Code Part 3"; Rec."Variant Code Part 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 3 field';
                }
                field("Variant Code Part 3 Length"; Rec."Variant Code Part 3 Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code Part 3 Length field';
                }
                field(GetVariantCodeExample; Rec.GetVariantCodeExample())
                {
                    ApplicationArea = All;
                    Caption = 'Example';
                    ToolTip = 'Specifies the value of the Example field';
                }
            }
        }
    }

    actions
    {
    }
}

