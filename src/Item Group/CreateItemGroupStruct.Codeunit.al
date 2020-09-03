codeunit 6014405 "NPR Create Item Group Struct."
{
    // NPR5.20/JDH /20160309  CASE 234014 Restructured code to use new function on item group
    // NPR5.30/MHA /20170126  CASE 264587 Added functions to Apply Dimension changes from Main Item Group to Sub Item Groups:
    //                                    OnInsertDefaultDim(),OnModifyDefaultDim(),OnDeleteDefaultDim(),ApplySubItemGroupDimensions()
    // NPR5.30/MHA /20170203  CASE 262977 Added functions to Apply Dimensions from Parent Item Group and aggregate changes to Sub Item Groups:
    //                                    OnInsertItemGroup(),OnModifyItemGroup(),CopyParentItemGroupDimensions(),CopyParentItemGroupSetups()


    trigger OnRun()
    var
        ItemGroup: Record "NPR Item Group";
    begin
        //-NPR5.20
        /*
        ItemGroup.RESET;
        IF ItemGroup.FINDSET THEN REPEAT
          IF (ItemGroup."Parent Item Group" = '') THEN BEGIN
            ItemGroup."Main Item Group" := FALSE;
            ItemGroup.Level := 0;
            ItemGroup."Check Done" := FALSE;
            ItemGroup."Entry No." := 0;
            ItemGroup.MODIFY;
            DescentTreeStructure(ItemGroup);
          END;
        UNTIL ItemGroup.NEXT = 0;
        */

        ItemGroup.ModifyAll(Level, 0);
        ItemGroup.ModifyAll("Sorting-Key", '');

        ItemGroup.SetFilter("Parent Item Group No.", '%1', '');
        if ItemGroup.FindSet then
            repeat
                ItemGroup.UpdateSortKey(ItemGroup);
            until ItemGroup.Next = 0;
        //+NPR5.20

    end;

    var
        Text001: Label 'Updating Item Group @1@@@@@@';
        Text002: Label 'Apply Dimension change on Sub Item Groups?';
        Text003: Label 'Apply Dimensions from Parent Item Group?';
        Text004: Label 'Apply changes on Sub Item Groups?';

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 540, 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertDefaultDim(var Rec: Record "Default Dimension"; BelowxRec: Boolean; var xRec: Record "Default Dimension"; var AllowInsert: Boolean)
    begin
        //-NPR5.30 [264587]
        if Rec.IsTemporary then
            exit;
        if Rec."Table ID" <> DATABASE::"NPR Item Group" then
            exit;

        ApplySubItemGroupDimensions(Rec, false, true);
        //+NPR5.30 [264587]
    end;

    [EventSubscriber(ObjectType::Page, 540, 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyDefaultDim(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; var AllowModify: Boolean)
    begin
        //-NPR5.30 [264587]
        if Rec.IsTemporary then
            exit;
        if Rec."Table ID" <> DATABASE::"NPR Item Group" then
            exit;
        if xRec."Dimension Value Code" = Rec."Dimension Value Code" then
            exit;

        ApplySubItemGroupDimensions(Rec, false, true);
        //+NPR5.30 [264587]
    end;

    [EventSubscriber(ObjectType::Page, 540, 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteDefaultDim(var Rec: Record "Default Dimension"; var AllowDelete: Boolean)
    begin
        //-NPR5.30 [264587]
        if Rec.IsTemporary then
            exit;
        if Rec."Table ID" <> DATABASE::"NPR Item Group" then
            exit;

        ApplySubItemGroupDimensions(Rec, true, true);
        //+NPR5.30 [264587]
    end;

    [EventSubscriber(ObjectType::Table, 6014410, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertItemGroup(var Rec: Record "NPR Item Group"; RunTrigger: Boolean)
    begin
        //-NPR5.30 [262977]
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;
        if Rec."Parent Item Group No." = '' then
            exit;

        CopyParentItemGroupDimensions(Rec, false);
        //+NPR5.30 [262977]
    end;

    [EventSubscriber(ObjectType::Table, 6014410, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyItemGroup(var Rec: Record "NPR Item Group"; var xRec: Record "NPR Item Group"; RunTrigger: Boolean)
    begin
        //-NPR5.30 [262977]
        if Rec.IsTemporary then
            exit;

        if RunTrigger then begin
            if Format(Rec) <> Format(xRec) then
                CopyParentItemGroupSetups(Rec, true);
        end;

        if Rec."Parent Item Group No." = '' then
            exit;
        if Rec."Parent Item Group No." = xRec."Parent Item Group No." then
            exit;

        CopyParentItemGroupDimensions(Rec, xRec."Parent Item Group No." <> '');
        //+NPR5.30 [262977]
    end;

    local procedure "--- Dimension Update"()
    begin
    end;

    local procedure ApplySubItemGroupDimensions(DefaultDimension: Record "Default Dimension"; DeleteDimension: Boolean; "Query": Boolean)
    var
        DefaultDimension2: Record "Default Dimension";
        ItemGroup: Record "NPR Item Group";
    begin
        //+NPR5.30 [264587]
        if DefaultDimension.IsTemporary then
            exit;
        if DefaultDimension."Table ID" <> DATABASE::"NPR Item Group" then
            exit;

        ItemGroup.SetRange("Parent Item Group No.", DefaultDimension."No.");
        if ItemGroup.IsEmpty then
            exit;

        if not GuiAllowed then
            Query := false;
        if Query then
            if not Confirm(Text002) then
                exit;

        ItemGroup.FindSet;
        repeat
            if DeleteDimension then begin
                if DefaultDimension2.Get(DATABASE::"NPR Item Group", ItemGroup."No.", DefaultDimension."Dimension Code") then
                    DefaultDimension2.Delete(true);
            end else begin
                if not DefaultDimension2.Get(DATABASE::"NPR Item Group", ItemGroup."No.", DefaultDimension."Dimension Code") then begin
                    DefaultDimension2.Init;
                    DefaultDimension2 := DefaultDimension;
                    DefaultDimension2."No." := ItemGroup."No.";
                    DefaultDimension2.Insert(true);
                end else begin
                    DefaultDimension2.TransferFields(DefaultDimension, false);
                    DefaultDimension2.Modify(true);
                end;
            end;
            ApplySubItemGroupDimensions(DefaultDimension2, DeleteDimension, false);
        until ItemGroup.Next = 0;
        //+NPR5.30 [264587]
    end;

    local procedure CopyParentItemGroupDimensions(ItemGroup: Record "NPR Item Group"; "Query": Boolean)
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
    begin
        //-NPR5.30 [262977]
        if ItemGroup."Parent Item Group No." = '' then
            exit;

        DefaultDimension.SetRange("Table ID", DATABASE::"NPR Item Group");
        DefaultDimension.SetRange("No.", ItemGroup."Parent Item Group No.");
        if DefaultDimension.IsEmpty then
            exit;

        if not GuiAllowed then
            Query := false;
        if Query then
            if not Confirm(Text003) then
                exit;

        DefaultDimension.FindSet;
        repeat
            if not DefaultDimension2.Get(DATABASE::"NPR Item Group", ItemGroup."No.", DefaultDimension."Dimension Code") then begin
                DefaultDimension2.Init;
                DefaultDimension2 := DefaultDimension;
                DefaultDimension2."No." := ItemGroup."No.";
                DefaultDimension2.Insert(true);
            end else begin
                DefaultDimension2.TransferFields(DefaultDimension, false);
                DefaultDimension2.Modify(true);
            end;
            ApplySubItemGroupDimensions(DefaultDimension2, false, false);
        until DefaultDimension.Next = 0;
        //+NPR5.30 [262977]
    end;

    local procedure CopyParentItemGroupSetups(ItemGroup: Record "NPR Item Group"; "Query": Boolean)
    var
        ItemGroup2: Record "NPR Item Group";
    begin
        //-NPR5.30 [262977]
        ItemGroup2.SetRange("Parent Item Group No.", ItemGroup."No.");
        if ItemGroup2.IsEmpty then
            exit;

        if not GuiAllowed then
            Query := false;
        if Query then
            if not Confirm(Text004) then
                exit;

        ItemGroup2.FindSet;
        repeat
            ItemGroup2.CopyParentItemGroupSetup(ItemGroup2);
            ItemGroup2.Modify;
        until ItemGroup2.Next = 0;
        //+NPR5.30 [262977]
    end;
}

