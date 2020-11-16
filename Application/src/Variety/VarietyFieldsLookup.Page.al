page 6059979 "NPR Variety Fields Lookup"
{
    // VRT1.11/JDH /20160602 CASE 242940 Created
    // NPR5.32/JDH /20170509 CASE 274170 Making sure setup is updated
    // NPR5.47/JDH /20181012 CASE 324997 Added filter to hide disabled fileds and changed key

    Caption = 'Variety Fields Lookup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Variety Field Setup";
    SourceTableView = SORTING("Sort Order")
                      WHERE(Disabled = CONST(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Secondary Type"; "Secondary Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Secondary Field No."; "Secondary Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Secondary Description"; "Secondary Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        //-NPR5.32 [274170]
        UpdateToLatestVersion;
        //+NPR5.32 [274170]
    end;
}

