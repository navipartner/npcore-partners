page 6059979 "NPR Variety Fields Lookup"
{
    Extensible = False;
    // VRT1.11/JDH /20160602 CASE 242940 Created
    // NPR5.32/JDH /20170509 CASE 274170 Making sure setup is updated
    // NPR5.47/JDH /20181012 CASE 324997 Added filter to hide disabled fileds and changed key

    Caption = 'Variety Fields Lookup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Variety Field Setup";
    SourceTableView = SORTING("Sort Order")
                      WHERE(Disabled = CONST(false));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Type"; Rec."Secondary Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Field No."; Rec."Secondary Field No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Description"; Rec."Secondary Description")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Secondary Field Description field';
                    ApplicationArea = NPRRetail;
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
        Rec.UpdateToLatestVersion();
        //+NPR5.32 [274170]
    end;
}

