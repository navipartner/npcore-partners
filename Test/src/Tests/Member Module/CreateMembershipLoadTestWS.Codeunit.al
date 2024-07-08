codeunit 85138 "NPR CreateMembershipLoadTestWS"
{
    procedure POS_OnNewMembershipLoadTest(ItemNo: Code[20]; SaleLineCount: Integer; BatchId: Code[10])
    var
        PosSaleLine: Record "NPR POS Sale Line";
        MembershipRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        i: Integer;
        UnitPrice: Decimal;
        ReturnCode: Integer;
    begin
        Randomize();

        PosSaleLine."Register No." := StrSubstNo('WS-%1', 1000000 - Random(900000));
        PosSaleLine."Sales Ticket No." := StrSubstNo('WS-%1-%2', BatchId, 1000000 - Random(900000) + 1);
        PosSaleLine.Date := Today();
        PosSaleLine."Sale Type" := PosSaleLine."Sale Type"::Sale;
        PosSaleLine."Line Type" := PosSaleLine."Line Type"::Item;
        PosSaleLine."Line No." := 0;
        PosSaleLine."No." := ItemNo;
        PosSaleLine.Quantity := 1;

        // Simulate POS sale line registration
        for i := 1 to SaleLineCount do begin
            PosSaleLine."Line No." := (i * 10000);
            PosSaleLine.Insert();
            PosSaleLine.SetRecFilter();

            ReturnCode := MembershipRetailIntegration.NewMemberSalesInfoCapture(PosSaleLine);
            if (ReturnCode <> 1) then
                Error('NewMemberSales failed with code: %1', MembershipRetailIntegration.GetErrorText(ReturnCode));

            Commit(); // There will be natural commit between users entering sale lines
        end;

        // Simulate membership activation as in end-of-sale, should be a single transaction
        for i := 1 to SaleLineCount do begin
            UnitPrice := (Random(999) + 1000) / 100;
            MembershipRetailIntegration.IssueMembershipFromEndOfSaleWorker(PosSaleLine."Sales Ticket No.", (i * 10000), Today(), UnitPrice, UnitPrice, UnitPrice * 1.25, 'WS Load test', 1.0);
        end;

        // Clean-up
        for i := 1 to SaleLineCount do begin
            PosSaleLine.SetFilter("Line No.", '=%1', (i * 10000));
            if (PosSaleLine.FindFirst()) then
                PosSaleLine.Delete();
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMembInfoCaptureDialog', '', true, true)]
    local procedure OnUserInput(var MemberInfoCapture: Record "NPR MM Member Info Capture"; StandardUserInterface: Boolean; var LookupOK: Boolean)
    var
        MemberTestLib: Codeunit "NPR Library - Member Module";
        MemberInfoCapture2: Record "NPR MM Member Info Capture";
    begin
        MemberInfoCapture2.SetFilter("Receipt No.", '=%1', MemberInfoCapture."Receipt No.");
        MemberInfoCapture2.SetFilter("Line No.", '=%1', MemberInfoCapture."Line No.");
        if (MemberInfoCapture2.FindSet()) then begin
            repeat
                MemberInfoCapture2."Company Name" := MemberInfoCapture."Receipt No.";

                MemberTestLib.GenerateText(MemberInfoCapture2."First Name", 15);
                MemberTestLib.GenerateText(MemberInfoCapture2."Middle Name", 8);
                MemberTestLib.GenerateText(MemberInfoCapture2."Last Name", 20);
                MemberTestLib.GeneratePhoneNumber(MemberInfoCapture2."Phone No.");
                MemberTestLib.GenerateText(MemberInfoCapture2."Social Security No.", MaxStrLen(MemberInfoCapture2."Social Security No."));
                MemberTestLib.GenerateText(MemberInfoCapture2.Address, MaxStrLen(MemberInfoCapture2.Address));
                MemberTestLib.GenerateText(MemberInfoCapture2.City, MaxStrLen(MemberInfoCapture2.City));
                MemberTestLib.GenerateText(MemberInfoCapture2.Country, MaxStrLen(MemberInfoCapture2.Country));

                MemberTestLib.GenerateText(MemberInfoCapture2."E-Mail Address", 50);
                MemberInfoCapture2."E-Mail Address"[3 + Random(10)] := '@';
                MemberInfoCapture2."E-Mail Address"[StrLen(MemberInfoCapture2."E-Mail Address") - 3] := '.';

                MemberTestLib.GenerateCode(MemberInfoCapture2."Post Code Code", MaxStrLen(MemberInfoCapture2."Post Code Code"));
                MemberInfoCapture2."Country Code" := '';

                MemberTestLib.GenerateCode(MemberInfoCapture2."User Logon ID", MaxStrLen(MemberInfoCapture2."User Logon ID"));
                MemberTestLib.GenerateText(MemberInfoCapture2."Password SHA1", MaxStrLen(MemberInfoCapture2."Password SHA1"));

                MemberInfoCapture2.Gender := MemberInfoCapture2.Gender::OTHER;
                MemberInfoCapture2.Birthday := CalcDate('<-50Y+7D>', Today());
                MemberInfoCapture2."News Letter" := MemberInfoCapture2."News Letter"::YES;
                MemberInfoCapture2."Notification Method" := MemberInfoCapture2."Notification Method"::EMAIL;
                MemberInfoCapture2.Modify();
            until (MemberInfoCapture2.Next() = 0);
        end;

        LookupOK := true;
    end;

}