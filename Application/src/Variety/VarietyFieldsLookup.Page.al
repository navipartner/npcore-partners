page 6059979 "NPR Variety Fields Lookup"
{
    // VRT1.11/JDH /20160602 CASE 242940 Created
    // NPR5.32/JDH /20170509 CASE 274170 Making sure setup is updated
    // NPR5.47/JDH /20181012 CASE 324997 Added filter to hide disabled fileds and changed key

    Caption = 'Variety Fields Lookup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Secondary Type"; "Secondary Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Type field';
                }
                field("Secondary Field No."; "Secondary Field No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Field No. field';
                }
                field("Secondary Description"; "Secondary Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Field Description field';
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

