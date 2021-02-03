codeunit 6014501 "NPR Convert used goods"
{

    TableNo = "NPR Used Goods Registration";

    trigger OnRun()
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if "Item No. Created" <> '' then
            Error(t001, "Item No. Created");
        RetailSetup.Get;
        FotoOps.Get;
        RetailSetup.TestField("Internal EAN No. Management");
        Nrseriestyring.InitSeries(RetailSetup."Internal EAN No. Management", RetailSetup."Internal EAN No. Management", 0D, VareNr, Nummerserie);

        if DelChr(VareNr, '=', '1234567890') <> '' then
            Error(t002);
        if StrLen(VareNr) > 10 then
            Error(t004);
        VareNr := StrSubstNo(t003, RetailSetup."EAN-Internal") + PadStr('', 10 - StrLen(VareNr), '0') + VareNr;
        VareNr := VareNr + Format(StrCheckSum(VareNr, '131313131313'));
        if StrCheckSum(VareNr, '1313131313131') <> 0 then
            Error(t005);
        if not Vare.Get(VareNr) then begin
            Vare.Init;
            Vare."NPR Second-hand number" := "No.";
            Vare."NPR Second-hand" := true;
            Vare.Validate("No.", VareNr);
            Vare.Insert();
            Vare.Validate(Description, Subject);
            Vare.Validate("Search Description", "Search Name");
            Vare.Validate("NPR Item Group", "Item Group No.");
            Vare.Validate("Unit Price", "Salgspris inkl. Moms");
            Vare.Validate("Unit Cost", "Unit Cost");
            ItemCrossReference.Init;
            ItemCrossReference."Item No." := Vare."No.";
            ItemCrossReference."Unit of Measure" := Vare."Base Unit of Measure";
            ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
            ItemCrossReference."Cross-Reference No." := Vare."No.";
            ItemCrossReference.Description := Vare.Description;
            ItemCrossReference.Insert();
            


            if FotoOps."Used Goods Serial No. Mgt." then begin
                if Serienummer <> '' then begin
                    FotoOps.TestField("Used Goods Item Tracking Code");
                    "Brugtvare lagermetode" := "Brugtvare lagermetode"::Serienummer;
                    Vare."Item Tracking Code" := FotoOps."Used Goods Item Tracking Code";
                end else begin
                    "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";
                end;
            end else
                "Brugtvare lagermetode" := FotoOps."Used Goods Inventory Method";
            Vare.Validate("Costing Method", "Brugtvare lagermetode");
            Varegruppe.Get(Vare."NPR Item Group");
            Varegruppe.TestField("Inventory Posting Group");
            VirkBogfGrp.Get(Varegruppe."Gen. Bus. Posting Group");

            if Puljemomsordning then
                Vare.Validate("VAT Bus. Posting Gr. (Price)", FotoOps."Used Goods Gen. Bus. Post. Gr.")
            else
                Vare.Validate("VAT Bus. Posting Gr. (Price)", VirkBogfGrp."Def. VAT Bus. Posting Group");
            Vare.Validate("Inventory Posting Group", Varegruppe."Inventory Posting Group");
            Vare.Validate("Gen. Prod. Posting Group", Varegruppe."Gen. Prod. Posting Group");
            Vare."VAT Prod. Posting Group" := Varegruppe."VAT Prod. Posting Group";
            Vare.Validate("VAT Prod. Posting Group", Varegruppe."VAT Prod. Posting Group");
            "Item No. Created" := VareNr;
            Modify;
            Vare.Modify;
        end;
        Kosterreg := Rec;
        CreateItemJournal(Vare, Kosterreg);
        
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        FotoOps: Record "NPR Retail Contr. Setup";
        Vare: Record Item;
        Varegruppe: Record "NPR Item Group";
        Kosterregistrering1: Record "NPR Used Goods Registration";
        Kosterreg: Record "NPR Used Goods Registration";
        VirkBogfGrp: Record "Gen. Business Posting Group";
        VareNr: Code[13];
        Nrseriestyring: Codeunit NoSeriesManagement;
        t001: Label 'Item %1 has already been created on this card!';
        t002: Label 'only numbers are allowed to generate EAN-codes!';
        t003: Label '%1';
        t004: Label 'No more than 10 numbers can be typed when generating the EAN-number!';
        t005: Label 'Checkdigit on EAN Code is incorrect!';

    procedure Assistedit(glKoster: Record "NPR Used Goods Registration"): Boolean
    begin
        with Kosterregistrering1 do begin
            Kosterregistrering1 := Kosterreg;
            RetailSetup.Get;
            RetailSetup.TestField("Internal EAN No. Management");
            if Nrseriestyring.SelectSeries(RetailSetup."Internal EAN No. Management", glKoster.Nummerserie, Nummerserie) then begin
                RetailSetup.Get;
                Nrseriestyring.SetSeries(VareNr);
                Kosterreg := Kosterregistrering1;
                exit(true);
            end;
        end;
    end;

    procedure UsedGoods2SalesCreditMemo(UsedGoodsRegistration: Record "NPR Used Goods Registration")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        ItemGroup: Record "NPR Item Group";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Txt001: Label 'Sales Credit Memo %1 created.';
        UsedGoodsRegistrationRec: Record "NPR Used Goods Registration";
        LineNo: Integer;
        Txt002: Label 'Created from Used Goods Registration %1';
    begin
        UsedGoodsRegistration.TestField(Blocked, false);
        UsedGoodsRegistration.TestField("Purchased By Customer No.");
        UsedGoodsRegistration.TestField("Salesperson Code");

        SalesHeader.Init;
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", UsedGoodsRegistration."Purchased By Customer No.");
        SalesHeader.Validate("Salesperson Code", UsedGoodsRegistration."Salesperson Code");
        SalesHeader.Validate("External Document No.", UsedGoodsRegistration.Link);
        SalesHeader.Validate("Posting Date", UsedGoodsRegistration."Purchase Date");
        SalesHeader.Modify(true);

        LineNo := 0;

        UsedGoodsRegistrationRec.SetRange(Link, UsedGoodsRegistration.Link);
        UsedGoodsRegistrationRec.SetFilter("Item Group No.", '<> %1', '');
        if UsedGoodsRegistrationRec.FindSet then
            repeat
                UsedGoodsRegistrationRec.TestField(Blocked, false);
                ItemGroup.Get(UsedGoodsRegistrationRec."Item Group No.");
                GeneralPostingSetup.Get(ItemGroup."Gen. Bus. Posting Group", ItemGroup."Gen. Prod. Posting Group");

                SalesLine.Init;
                SalesLine.Validate("Document Type", SalesLine."Document Type"::"Credit Memo");
                SalesLine.Validate("Document No.", SalesHeader."No.");
                LineNo += 10000;
                SalesLine."Line No." := LineNo;
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                SalesLine.Validate("No.", GeneralPostingSetup."Purch. Account");
                SalesLine.Validate(Description, StrSubstNo(Txt002, UsedGoodsRegistrationRec."No."));
                SalesLine.Validate("Unit Price", UsedGoodsRegistrationRec."Unit Cost");
                SalesLine.Validate(Quantity, 1);
                SalesLine.Insert(true);

                UsedGoodsRegistrationRec.Validate(Blocked, true);
                UsedGoodsRegistrationRec.Modify(true);
            until UsedGoodsRegistrationRec.Next = 0;

        Message(Txt001, SalesHeader."No.");
        
    end;

    procedure CreateItemJournal(Item: Record Item; var UsedGoodsRegistration: Record "NPR Used Goods Registration")
    var
        RetailSetup: Record "NPR Retail Setup";
        ReservationEntry: Record "Reservation Entry";
        TempItemJournalLine: Record "Item Journal Line" temporary;
        ItemGroup: Record "NPR Item Group";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        TempItemJournalLine.DeleteAll;
        TempItemJournalLine."Line No." := 10000;
        TempItemJournalLine."Document No." := UsedGoodsRegistration."No.";
        TempItemJournalLine."Entry Type" := TempItemJournalLine."Entry Type"::Purchase;
        TempItemJournalLine."Source No." := UsedGoodsRegistration."Purchased By Customer No.";
        TempItemJournalLine."Posting Date" := Today;
        TempItemJournalLine."Document Date" := UsedGoodsRegistration."Purchase Date";
        TempItemJournalLine.Validate("Item No.", Item."No.");
        TempItemJournalLine.Validate(Quantity, 1);
        TempItemJournalLine.Validate(Amount, UsedGoodsRegistration."Unit Cost");
        UsedGoodsRegistration.TestField("Item Group No.");
        ItemGroup.Get(UsedGoodsRegistration."Item Group No.");
        TempItemJournalLine."Gen. Bus. Posting Group" := ItemGroup."Gen. Bus. Posting Group";
        TempItemJournalLine.Description := UsedGoodsRegistration.Subject;
        TempItemJournalLine."Salespers./Purch. Code" := UsedGoodsRegistration."Salesperson Code";
        TempItemJournalLine."Source Code" := RetailSetup."Posting Source Code";

        TempItemJournalLine."Location Code" := UsedGoodsRegistration."Location Code";
        TempItemJournalLine.Insert();

        ReservationEntry.SetCurrentKey(Positive);
        ReservationEntry.SetRange(Positive, false);
        if ReservationEntry.FindLast then;
        ReservationEntry.Init;
        ReservationEntry."Entry No." += 1;
        ReservationEntry.Positive := false;
        ReservationEntry."Item No." := Item."No.";
        ReservationEntry."Location Code" := UsedGoodsRegistration."Location Code";
        ReservationEntry."Quantity (Base)" := 1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := 0;
        ReservationEntry.Quantity := 1;
        ReservationEntry."Qty. to Handle (Base)" := 1;
        ReservationEntry."Qty. to Invoice (Base)" := 1;
        ReservationEntry."Creation Date" := Today;
        ReservationEntry."Qty. per Unit of Measure" := 1;
        ReservationEntry."Source ID" := TempItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := TempItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := TempItemJournalLine."Line No.";
        ReservationEntry."Expected Receipt Date" := Today;
        ReservationEntry."Serial No." := UsedGoodsRegistration.Serienummer;
        ReservationEntry."Created By" := UsedGoodsRegistration."Salesperson Code";
        ReservationEntry.Insert;
        ItemJnlPostLine.Run(TempItemJournalLine);
    end;
}

