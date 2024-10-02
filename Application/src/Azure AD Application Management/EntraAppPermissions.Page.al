page 6184804 "NPR Entra App Permissions"
{
    PageType = ListPart;
    UsageCategory = None;
    Caption = 'Entra App Permissions';
    SourceTable = "NPR Entra App Permission";
    SourceTableTemporary = true;
    Extensible = False;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(PermissionSets)
            {
                field("Permission Set ID"; Rec."Permission Set ID")
                {
                    Caption = 'Permission Set ID';
                    ToolTip = 'Specifies the ID of the permission set.';
                    ApplicationArea = NPRRetail;
                }
                field("Permission Set Name"; Rec."Permission Set Name")
                {
                    Caption = 'Permission Set Name';
                    ToolTip = 'Specifies the name of the permission set.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetTableView(var TempPermissionSet: Record "NPR Entra App Permission" temporary)
    begin
        Rec.Copy(TempPermissionSet, true);
        CurrPage.Update(false);
    end;
}