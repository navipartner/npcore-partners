codeunit 6014421 "NPR Retail Item Jnl. Mgt."
{
    // NPR5.30/TJ  /20170227 CASE 267424 Added new function GetItem
    // NPR5.30/NPKNAV/20170310  CASE 266258 Transport NPR5.30 - 26 January 2017


    trigger OnRun()
    begin
    end;

    var
        JournalDescription: Label 'Retail %1 journal';
        ReccuringJnlDesc: Label 'Recurring retail %1 journal';
        NamePrefix: Label 'R%1-%2';
        ReccuringTxt: Label 'REC';
        OldItemNo: Code[20];

    procedure FindTemplate(PageID: Integer): Boolean
    var
        ItemJnlTemplate: Record "Item Journal Template";
    begin
        ItemJnlTemplate.SetRange("Page ID", PageID);
        exit(ItemJnlTemplate.FindFirst);
    end;

    procedure CreateTemplate(PageID: Integer; PageTemplate: Option; RecurringJnl: Boolean)
    var
        ItemJnlTemplate: Record "Item Journal Template";
    begin
        ItemJnlTemplate.Init;
        ItemJnlTemplate.Recurring := RecurringJnl;
        ItemJnlTemplate.Validate(Type, PageTemplate);
        ItemJnlTemplate.Validate("Page ID", PageID);
        if RecurringJnl then begin
            ItemJnlTemplate.Name := CopyStr(StrSubstNo(NamePrefix, ReccuringTxt, ItemJnlTemplate.Type), 1, MaxStrLen(ItemJnlTemplate.Name));
            ItemJnlTemplate.Description := StrSubstNo(ReccuringJnlDesc, LowerCase(Format(ItemJnlTemplate.Type)));
        end else begin
            ItemJnlTemplate.Name := CopyStr(StrSubstNo(NamePrefix, '', ItemJnlTemplate.Type), 1, MaxStrLen(ItemJnlTemplate.Name));
            ItemJnlTemplate.Description := StrSubstNo(JournalDescription, LowerCase(Format(ItemJnlTemplate.Type)));
        end;
        ItemJnlTemplate.Insert;
    end;

    procedure GetItem(ItemNo: Code[20]; var ItemDescription: Text[50])
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        if ItemNo <> OldItemNo then begin
            ItemDescription := '';
            if ItemNo <> '' then begin
                ItemReference.SetRange("Reference No.", ItemNo);
                if ItemReference.FindFirst then
                    ItemNo := ItemReference."Item No.";
                if Item.Get(ItemNo) then
                    ItemDescription := Item.Description;
            end;
            OldItemNo := ItemNo;
        end;
    end;
}

