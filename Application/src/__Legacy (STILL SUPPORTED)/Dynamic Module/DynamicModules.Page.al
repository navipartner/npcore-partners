page 6014499 "NPR Dynamic Modules"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018

    Caption = 'Dynamic Modules';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Dynamic Module";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Module Name"; "Module Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Module Name field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Load Modules")
            {
                Caption = 'Load Modules';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Load Modules action';

                trigger OnAction()
                begin
                    DiscoverModules;
                    CurrPage.Update(false);
                end;
            }
            action(ShowModuleSettings)
            {
                Caption = 'Show Module Settings';
                Image = ShowSelected;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Module Settings action';

                trigger OnAction()
                begin
                    DynamicModuleHelper.ShowModuleSettings(Rec);
                end;
            }
            action(ShowAllSettings)
            {
                Caption = 'Show All Settings';
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show All Settings action';

                trigger OnAction()
                begin
                    DynamicModuleHelper.ShowAllSettings();
                end;
            }
        }
    }

    var
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
}

