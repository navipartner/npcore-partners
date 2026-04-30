#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150934 "NPR NPRE Menu Items Part"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Restaurant Menu Items';
    PageType = ListPart;
    SourceTable = "NPR NPRE Menu Item";
    AutoSplitKey = true;
    SourceTableView = sorting("Restaurant Code", "Menu Code", "Category Code", "Sort Key")
                      order(ascending);

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number linked to this menu item.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item description.';
                    DrillDown = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the variant code for the item.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the status of the menu item. Active items are shown on the menu, Inactive (visible) items are shown but cannot be ordered, and Inactive (hidden) items are not shown.';
                }
                field("Captions Filled"; Rec."Captions Filled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether captions have been filled.';
                    DrillDown = false;
                }
                field("Has Addons"; Rec."Has Addons")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the item has addons.';
                    DrillDown = false;
                }
                field("Has Upsells"; Rec."Has Upsells")
                {
                    ToolTip = 'Specifies whether the item has upsells.';
                    DrillDown = false;
                }
                field("Has Picture"; Rec."Has Picture")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the item has a picture.';
                    DrillDown = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(EditDetails)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Captions & Details';
                Image = Edit;
                ToolTip = 'Add title, description and nutritional info for this menu item.';
                RunObject = Page "NPR NPRE Menu Item Translat.";
                RunPageLink = "External System Id" = field(SystemId);
            }
            action(OpenItemAddons)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Item Addons';
                Image = ItemGroup;
                Enabled = Rec."Has Addons";
                ToolTip = 'Open the item addons for this menu item.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ItemAddon: Record "NPR NpIa Item AddOn";
                begin
                    if not Item.Get(Rec."Item No.") then
                        exit;

                    if Item."NPR Item AddOn No." = '' then
                        exit;

                    if not ItemAddon.Get(Item."NPR Item AddOn No.") then
                        exit;

                    Page.Run(Page::"NPR NpIa Item AddOn Card", ItemAddon);
                end;
            }
            action(Upsells)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Upsells';
                Image = Suggest;
                RunObject = Page "NPR NPRE Upsell List";
                RunPageLink = "External Table" = const("NPR NPRE Upsell Table"::MenuItem), "External System Id" = field(SystemId);
                ToolTip = 'View and manage upsells for this menu item.';
            }
            action(Moveup)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Move Up';
                Image = MoveUp;
                ToolTip = 'Move this item up in the sort order.';
                trigger OnAction()
                begin
                    Rec.MoveUp();
                    CurrPage.Update(true);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Move Down';
                Image = MoveDown;
                ToolTip = 'Move this item down in the sort order.';
                trigger OnAction()
                begin
                    Rec.MoveDown();
                    CurrPage.Update(true);
                end;
            }
            action(ViewEditPicture)
            {
                ApplicationArea = NPRRetail;
                Caption = 'View/Edit Picture';
                Image = Picture;
                ToolTip = 'View or edit the picture for this menu item.';

                trigger OnAction()
                var
                    MenuItemPictureCard: Page "NPR NPREMenuItemPictureCard";
                begin
                    MenuItemPictureCard.SetRecord(Rec);
                    MenuItemPictureCard.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Has Addons", "Item Description", "Has Picture");
    end;
}
#endif
