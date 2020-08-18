page 6150628 "POS Payment Bin Checkpoint"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.40/TSA /20180306 CASE 307267 Corrected drill down behavior on money to count, checkpoints that are zero are not created
    // NPR5.40/TSA /20180306 CASE 307267 Added PageMode to handle preliminary, final & transfer
    // NPR5.42/NPKNAV/20180525  CASE 306858-01 Transport NPR5.42 - 25 May 2018
    // NPR5.43/TSA /20180427 CASE 311964 Made the transfer experience better
    // NPR5.45/TSA /20180726 CASE 322769 Added filter for "Include in Counting"
    // NPR5.45/TSA /20180727 CASE 311964 Assigning bin checkpoint type, adding Transfer Amount fields
    // NPR5.46/TSA /20180913 CASE 328326 Adding View mode
    // NPR5.46/TSA /20181002 CASE 322769 Adding Auto-Count mode
    // NPR5.47/TSA /20181018 CASE 322769 Fixed Virtual counting bin selection
    // NPR5.49/TSA /20190314 CASE 348458 Added Forced Blind Count
    // NPR5.49/TSA /20190405 CASE 351350 Removed hide of the "Bank" transfer fields when doing BIN_TRANSFER
    // NPR5.50/TSA /20190429 CASE 353293 Handled the special scenario, when no bin checkpoint is included in manuel balancing
    // NPR5.54/TSA /20200224 CASE 389250 Dont assume zero count when counting is virtual, allow negative transfer amount
    // NPR5.55/SARA/20200602 CASE 405110 Run page Touch Screen - Balancing Line as Editable by default

    Caption = 'POS Payment Bin Checkpoint';
    //DataCaptionFields = Type,Field2,Field3;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "POS Payment Bin Checkpoint";

    layout
    {
        area(content)
        {
            group(Counting)
            {
                repeater(Control6014417)
                {
                    Editable = ViewMode = FALSE;
                    ShowCaption = false;
                    Visible = ShowCountingSection;
                    field(PaymentTypeNo;"Payment Type No.")
                    {
                        Editable = false;
                    }
                    field(Description;Description)
                    {
                        Editable = false;
                    }
                    field(PaymentBinNo;"Payment Bin No.")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field(PaymentMethodNo;"Payment Method No.")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field(CountedAmountInclFloat;"Counted Amount Incl. Float")
                    {
                        MinValue = 0;

                        trigger OnAssistEdit()
                        begin

                            OnAssistEditCounting ();
                        end;

                        trigger OnValidate()
                        begin

                            CountingDifference := CalculatedDifference ();
                            CalculateNewFloatAmount ();
                            CurrPage.Update (true);
                        end;
                    }
                    field(CalculatedAmountInclFloat;"Calculated Amount Incl. Float")
                    {
                        Editable = false;
                        Visible = NOT IsBlindCount;
                    }
                    field(CountingDifference;CountingDifference)
                    {
                        Caption = 'Difference';
                        Style = Unfavorable;
                        StyleExpr = CountingDifference <> 0;
                        Visible = NOT IsBlindCount;

                        trigger OnValidate()
                        begin

                            "Counted Amount Incl. Float" := "Calculated Amount Incl. Float" - CountingDifference;
                            CountingDifference := CalculatedDifference ();
                            CalculateNewFloatAmount ();
                            CurrPage.Update (true);
                        end;
                    }
                    field(Comment1;Comment)
                    {
                        Visible = NOT IsBlindCount;
                    }
                }
            }
            group("Closing & Transfer")
            {
                repeater(Control6014403)
                {
                    Editable = ViewMode = FALSE;
                    ShowCaption = false;
                    Visible = ShowClosingSection;
                    field("Payment Type No.";"Payment Type No.")
                    {
                        Editable = false;
                    }
                    field("Payment Method No.";"Payment Method No.")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field("Payment Bin No.";"Payment Bin No.")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field("Float Amount";"Float Amount")
                    {
                        Editable = false;
                    }
                    field("Counted Amount Incl. Float";"Counted Amount Incl. Float")
                    {
                        MinValue = 0;
                        Visible = false;

                        trigger OnAssistEdit()
                        begin

                            OnAssistEditCounting ();
                        end;

                        trigger OnValidate()
                        begin

                            CalculateNewFloatAmount ();
                            CurrPage.Update (true);
                        end;
                    }
                    field("Transfer In Amount";"Transfer In Amount")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field("Transfer Out Amount";"Transfer Out Amount")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field(NetTransfer;NetTransfer)
                    {
                        Caption = 'Transfered Amount';
                        Editable = false;
                    }
                    field("Calculated Amount Incl. Float";"Calculated Amount Incl. Float")
                    {
                        Editable = false;
                        Visible = NOT IsBlindCount;
                    }
                    field("New Float Amount";"New Float Amount")
                    {
                        Editable = PageMode = PageMode::FINAL_COUNT;
                        MinValue = 0;
                        Style = Strong;
                        StyleExpr = TRUE;

                        trigger OnValidate()
                        begin

                            "Bank Deposit Amount" := "Counted Amount Incl. Float" - "Move to Bin Amount" - "New Float Amount";

                            if ("Bank Deposit Amount" < 0) then
                              Error (INVALID_AMOUNT, "New Float Amount");

                            SelectBankBin ();
                            SelectSafeBin ();
                            CurrPage.Update (true);
                        end;
                    }
                    field("Bank Deposit Amount";"Bank Deposit Amount")
                    {
                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;

                        trigger OnValidate()
                        begin

                            CalculateNewFloatAmount ();
                            SelectBankBin();
                            CurrPage.Update (true);
                        end;
                    }
                    field("Bank Deposit Bin Code";"Bank Deposit Bin Code")
                    {
                        ShowMandatory = "Bank Deposit Amount" <> 0;
                    }
                    field("Bank Deposit Reference";"Bank Deposit Reference")
                    {
                        ShowMandatory = "Bank Deposit Amount" <> 0;
                    }
                    field("Move to Bin Amount";"Move to Bin Amount")
                    {
                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;

                        trigger OnValidate()
                        begin

                            CalculateNewFloatAmount ();
                            SelectSafeBin();

                            //-NPR5.45 [322769]
                            if (PageMode  = PageMode::TRANSFER) then
                              if (("Move to Bin Amount" <> 0) and ("Include In Counting" = "Include In Counting"::NO)) then
                                "Include In Counting" := "Include In Counting"::YES;
                            //-NPR5.45 [322769]

                            CurrPage.Update (true);
                        end;
                    }
                    field("Move to Bin Code";"Move to Bin Code")
                    {
                        ShowMandatory = "Move to bin amount" <> 0;
                    }
                    field("Move to Bin Reference";"Move to Bin Reference")
                    {
                        ShowMandatory = "Move to bin amount" <> 0;
                    }
                    field(Status;Status)
                    {
                    }
                    field("Checkpoint Bin Entry No.";"Checkpoint Bin Entry No.")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field("Payment Bin Entry Amount";"Payment Bin Entry Amount")
                    {
                        Editable = false;
                        Visible = false;
                    }
                    field("Payment Bin Entry Amount (LCY)";"Payment Bin Entry Amount (LCY)")
                    {
                        Editable = false;
                        Visible = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Count")
            {
                Caption = 'Count';
                Ellipsis = true;
                Image = CalculateRemainingUsage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CountingDifference := CalculatedDifference ();
        InvalidDistribution := "Counted Amount Incl. Float" <> ("Bank Deposit Amount" + "Move to Bin Amount" + "New Float Amount");

        NetTransfer := "Transfer In Amount" + "Transfer Out Amount";
    end;

    trigger OnClosePage()
    var
        HaveError: Boolean;
    begin

        //-+NPR5.42 [307267]
        if (PageMode = PageMode::PRELIMINARY_COUNT) then begin
          ModifyAll (Status, Status::READY);
          exit;
        end;

        HaveError := false;
        if (FindSet ()) then begin
          repeat
            HaveError := HaveError or
             ("Counted Amount Incl. Float" - "Bank Deposit Amount" - "Move to Bin Amount" <> "New Float Amount");
          until (Next () = 0);
        end;

        if (not HaveError) then begin
          SetFilter (Status, '=%1', Status::WIP);

          //-NPR5.43 [311964]
          //  IF (NOT ISEMPTY ()) THEN
          //    IF (CONFIRM (TextFinishCountingandPost, TRUE)) THEN
          //      MODIFYALL (Status, Status::READY);
          if (not IsEmpty ()) then begin
            if (PageMode = PageMode::TRANSFER) then
              if (Confirm (TextFinishTransfer, true)) then
                ModifyAll (Status, Status::READY);

            //-NPR5.46 [322769]
            // IF (PageMode = PageMode::FINAL_COUNT) THEN
            //   IF (CONFIRM (TextFinishCountingandPost, TRUE)) THEN
            //    MODIFYALL (Status, Status::READY);
            if (PageMode = PageMode::FINAL_COUNT) then begin
              SetFilter ("Include In Counting", '<>%1', "Include In Counting"::NO);
              if (Confirm (TextFinishCountingandPost, true)) then
                ModifyAll (Status, Status::READY);
            end;
            //+NPR5.46 [322769]

          end;
          //+NPR5.43 [311964]

        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin


        if ("Calculated Amount Incl. Float" > 0) then //-+NPR5.49 [348458]
          TestField (Status, Status::WIP);
    end;

    trigger OnOpenPage()
    var
        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        POSPaymentMethod: Record "POS Payment Method";
        POSPaymentBin: Record "POS Payment Bin";
    begin

        //-+NPR5.42 [307267]
        //SETFILTER ("Calculated Amount Incl. Float", '<>%1', 0);
        //-NPR5.43 [311964]

        //-NPR5.45 [311964]
         case PageMode of
          PageMode::TRANSFER : ModifyAll (Type, POSPaymentBinCheckpoint.Type::TRANSFER);
          PageMode::FINAL_COUNT : ModifyAll (Type, POSPaymentBinCheckpoint.Type::ZREPORT);
          PageMode::PRELIMINARY_COUNT : ModifyAll (Type, POSPaymentBinCheckpoint.Type::XREPORT);
         end;
        //+NPR5.45 [311964]


        //-NPR5.46 [322769]
        if (PageMode = PageMode::FINAL_COUNT) then begin

          POSPaymentBinCheckpoint.CopyFilters (Rec);
          POSPaymentBinCheckpoint.SetFilter ("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
          if (POSPaymentBinCheckpoint.FindSet ()) then begin
            repeat
              POSPaymentMethod.Get (POSPaymentBinCheckpoint."Payment Method No.");
              if (POSPaymentMethod."Bin for Virtual-Count" = '') then
                Error (AutoCountBin, POSPaymentMethod.TableCaption, POSPaymentMethod."Include In Counting", POSPaymentMethod.FieldCaption ("Bin for Virtual-Count"));

              POSPaymentBin.Get (POSPaymentMethod."Bin for Virtual-Count");

              POSPaymentBinCheckpoint."Counted Amount Incl. Float" := POSPaymentBinCheckpoint."Calculated Amount Incl. Float";

              //-NPR5.47 [322769]
              //  IF (POSPaymentBin."Bin Type" = POSPaymentBin."Bin Type"::BANK) THEN BEGIN
              //    POSPaymentBinCheckpoint.VALIDATE ("Bank Deposit Bin Code", POSPaymentMethod."Bin for Virtual-Count");
              //    POSPaymentBinCheckpoint.VALIDATE ("Bank Deposit Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
              //    POSPaymentBinCheckpoint."Bank Deposit Reference" := STRSUBSTNO ('%1:%2', POSPaymentBinCheckpoint."Payment Method No.", COPYSTR (UPPERCASE(DELCHR(FORMAT(CREATEGUID),'=','{}-')), 1, 7));
              //  END ELSE BEGIN
              //    POSPaymentBinCheckpoint.VALIDATE ("Move to Bin Code", POSPaymentMethod."Bin for Virtual-Count");
              //    POSPaymentBinCheckpoint.VALIDATE ("Move to Bin Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
              //    POSPaymentBinCheckpoint."Move to Bin Reference" := STRSUBSTNO ('%1:%2', POSPaymentBinCheckpoint."Payment Method No.", COPYSTR (UPPERCASE(DELCHR(FORMAT(CREATEGUID),'=','{}-')), 1, 7));
              //  END;
              POSPaymentBinCheckpoint."Move to Bin Code" := POSPaymentMethod."Bin for Virtual-Count";
              POSPaymentBinCheckpoint.Validate ("Move to Bin Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
              POSPaymentBinCheckpoint."Move to Bin Reference" := StrSubstNo ('%1:%2', POSPaymentBinCheckpoint."Payment Method No.", CopyStr (UpperCase(DelChr(Format(CreateGuid),'=','{}-')), 1, 7));
              //+NPR5.47 [322769]

              POSPaymentBinCheckpoint."New Float Amount" := 0;
              POSPaymentBinCheckpoint.Comment := AutoCount;

              //-NPR5.50 [353293]
              POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
              //+NPR5.50 [353293]

              POSPaymentBinCheckpoint.Modify ();

            until (POSPaymentBinCheckpoint.Next () = 0);
          end;

          //-NPR5.49 [348458]
          POSPaymentBinCheckpoint.Reset ();
          POSPaymentBinCheckpoint.CopyFilters (Rec);
          POSPaymentBinCheckpoint.SetFilter ("Calculated Amount Incl. Float", '<%1', 0);
          POSPaymentBinCheckpoint.SetFilter ("Include In Counting", '<>%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL); //-+NPR5.54 [389250]
          if (POSPaymentBinCheckpoint.FindSet ()) then begin
            repeat
              POSPaymentBinCheckpoint.Validate ("Counted Amount Incl. Float", 0);
              POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
              POSPaymentBinCheckpoint."New Float Amount" := 0;
              POSPaymentBinCheckpoint.Comment := AutoCount;
              POSPaymentBinCheckpoint.Modify ();
            until (POSPaymentBinCheckpoint.Next () = 0);
          end;
          //+NPR5.49 [348458]

        end;

        //-NPR5.49 [348458]
        if (IsBlindCount) then begin
          POSPaymentBinCheckpoint.Reset ();
          POSPaymentBinCheckpoint.CopyFilters (Rec);
          POSPaymentBinCheckpoint.SetFilter ("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::YES);
          if (POSPaymentBinCheckpoint.FindSet ()) then begin
            repeat
              POSPaymentBinCheckpoint."New Float Amount" := 0;
              POSPaymentBinCheckpoint.Modify ();
            until (POSPaymentBinCheckpoint.Next () = 0);
          end;
        end;
        //+NPR5.49 [348458]


        // //-NPR5.45 [322769]
        // IF (PageMode <> PageMode::TRANSFER) THEN
        //   SETFILTER ("Include In Counting", '<>%1', "Include In Counting"::NO);
        // //+NPR5.45 [322769]
        case PageMode of
          PageMode::FINAL_COUNT : SetFilter ("Include In Counting", '<>%1&<>%2', "Include In Counting"::NO, "Include In Counting"::VIRTUAL);
          PageMode::PRELIMINARY_COUNT : SetFilter ("Include In Counting", '<>%1', "Include In Counting"::NO);
          PageMode::TRANSFER : ;
          PageMode::VIEW : SetFilter ("Include In Counting", '<>%1', "Include In Counting"::NO);
        end;
        //+NPR5.46 [322769]


        if (PageMode = PageMode::TRANSFER) then begin
          POSPaymentBinCheckpoint.CopyFilters (Rec);
          if (POSPaymentBinCheckpoint.FindSet ()) then begin
            repeat
              POSPaymentBinCheckpoint.Validate ("Counted Amount Incl. Float", POSPaymentBinCheckpoint."Calculated Amount Incl. Float");
              POSPaymentBinCheckpoint.Modify ();

            until (POSPaymentBinCheckpoint.Next () = 0);
          end;
        end;
    end;

    var
        CountingDifference: Decimal;
        InvalidDistribution: Boolean;
        INVALID_AMOUNT: Label 'The amount %1 is invalid.';
        COMMENT_NO_DIFFERENCE: Label 'No difference.';
        COMMENT_DIFFERENCE: Label 'Difference counted vs calculated.';
        TextFinishCountingandPost: Label 'Do you want to finish counting and post results?';
        TextFinishTransfer: Label 'Do you want to finish transfer and post results?';
        TextSetupPaymentTypeMissing: Label 'No counting details have been setup for %1, enter counted amount/quantity as is.';
        PageMode: Option PRELIMINARY_COUNT,FINAL_COUNT,TRANSFER,VIEW;
        NetTransfer: Decimal;
        ShowCountingSection: Boolean;
        ShowClosingSection: Boolean;
        ViewMode: Boolean;
        AutoCountBin: Label '%1 is configured to %2, but there is no value specified for %3.';
        AutoCount: Label 'Calculated by Auto-Count.';
        IsBlindCount: Boolean;

    local procedure OnAssistEditCounting()
    var
        PaymentTypeDetailed: Record "Payment Type - Detailed";
        TouchScreenBalancingLine: Page "Touch Screen - Balancing Line";
        PaymentTypePrefix: Record "Payment Type - Prefix";
    begin

        PaymentTypeDetailed.SetFilter ("Payment No.", '=%1', "Payment Type No.");
        PaymentTypeDetailed.SetFilter ("Register No.", '=%1', GetRegisterNo ());
        if (PaymentTypeDetailed.IsEmpty ()) then begin

          // PaymentPrefix.SETFILTER("Register No.", Rec.GETFILTER("Register No."));

          PaymentTypePrefix.SetFilter ("Payment Type", '=%1', "Payment Type No.");
          if PaymentTypePrefix.FindSet() then begin
            repeat
              PaymentTypeDetailed.Init;
              PaymentTypeDetailed."Payment No." := "Payment Type No.";
              PaymentTypeDetailed."Register No." := GetRegisterNo ();
              PaymentTypeDetailed.Weight := PaymentTypePrefix.Weight;
              PaymentTypeDetailed.Insert ();

            until (PaymentTypePrefix.Next() = 0);
            Commit;
          end;
        end;

        if (PaymentTypeDetailed.IsEmpty ()) then
          Error (TextSetupPaymentTypeMissing, "Payment Type No.");

        TouchScreenBalancingLine.SetTableView (PaymentTypeDetailed);
        TouchScreenBalancingLine.LookupMode (true);
        TouchScreenBalancingLine.Editable (true);
        //-NPR5.55 [405110]
        //IF (TouchScreenBalancingLine.RUNMODAL() = ACTION::LookupOK) THEN BEGIN
        TouchScreenBalancingLine.Run();
        //+NPR5.55 [405110]
        "Counted Amount Incl. Float" := 0;
        if (PaymentTypeDetailed.FindSet()) then begin
          repeat
            "Counted Amount Incl. Float" += PaymentTypeDetailed.Amount;

          until (PaymentTypeDetailed.Next() = 0);
        end;
        //-NPR5.55 [405110]
        //END;
        //+NPR5.55 [405110]
        CountingDifference := CalculatedDifference ();
        CalculateNewFloatAmount ();
        CurrPage.Update (true);
    end;

    local procedure GetRegisterNo() RegisterNo: Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
    begin

        //-NPR5.42 [306858]
        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          exit (POSSetup.Register());
        end;

        exit ('NOREGISTER');
        //EXIT ('1');
        //+NPR5.42 [306858]
    end;

    local procedure GetPosUnitNo(): Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
    begin

        //-NPR5.42 [306858]
        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          POSSetup.GetPOSUnit (POSUnit);
          exit (POSUnit."No.");
        end;

        exit ('NOUNIT');
        //+NPR5.42 [306858]
    end;

    local procedure GetStoreCode(): Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        POSStore: Record "POS Store";
    begin
        //-NPR5.42 [306858]
        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          POSSetup.GetPOSStore (POSStore);
          exit (POSStore.Code);
        end;

        exit ('NOSTORE');
        //+NPR5.42 [306858]
    end;

    local procedure CalculatedDifference() Difference: Decimal
    begin

        Difference := "Calculated Amount Incl. Float" - "Counted Amount Incl. Float";
        Comment := COMMENT_DIFFERENCE;
        if (Difference = 0) then
          Comment := COMMENT_NO_DIFFERENCE;
    end;

    local procedure CalculateNewFloatAmount()
    begin

        "New Float Amount" := "Counted Amount Incl. Float" - "Bank Deposit Amount" - "Move to Bin Amount";

        if ("New Float Amount" < 0) then
          "New Float Amount" := 0;
    end;

    procedure SetTransferMode()
    begin
        //-NPR5.46 [328326]
        ShowCountingSection := false;
        ShowClosingSection := true;
        ViewMode := false;
        //+NPR5.46 [328326]

        PageMode := PageMode::TRANSFER;
    end;

    procedure SetCheckpointMode(Mode: Option PRELIMINARY,FINAL,VIEW)
    begin
        //-NPR5.46 [328326]
        // PageMode := PageMode::PRELIMINARY_COUNT;
        // IF (Mode = Mode::FINAL) THEN
        //  PageMode := PageMode::FINAL_COUNT;

        case Mode of
          Mode::PRELIMINARY :
            begin
              ShowCountingSection := true;
              ShowClosingSection := false;
              ViewMode := false;
              PageMode := PageMode::PRELIMINARY_COUNT;
            end;

          Mode::FINAL :
            begin
              ShowCountingSection := true;
              ShowClosingSection := true;
              ViewMode := false;
              PageMode := PageMode::FINAL_COUNT;
            end;

          else begin
            ShowCountingSection := true;
            ShowClosingSection := true;
            ViewMode := true;
            PageMode := PageMode::VIEW;
          end;
        end;
        //+NPR5.46 [328326]
    end;

    local procedure SelectBankBin()
    var
        POSPaymentBin: Record "POS Payment Bin";
    begin
        if ("Bank Deposit Amount" = 0) then begin
          "Bank Deposit Bin Code" := '';
          exit;
        end;

        //-NPR5.42 [306858]
        "Bank Deposit Reference" := StrSubstNo ('%1 %2', "Payment Method No.", CopyStr (UpperCase(DelChr(Format(CreateGuid),'=','{}-')), 1, 7));

        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        //IF (POSPaymentBin.COUNT() <> 1) THEN
        //  EXIT;

        if POSPaymentBin.IsEmpty () then
          exit;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter ("POS Store Code", '=%1', GetStoreCode ());
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Bank Deposit Bin Code", POSPaymentBin."No.");
          exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter ("Attached to POS Unit No.", '=%1', GetPosUnitNo ());
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Bank Deposit Bin Code", POSPaymentBin."No.");
          exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Bank Deposit Bin Code", POSPaymentBin."No.");
          exit;
        end;

        // POSPaymentBin.FINDFIRST ();
        // VALIDATE ("Bank Deposit Bin Code", POSPaymentBin."No.");
        //+NPR5.42 [306858]
    end;

    local procedure SelectSafeBin()
    var
        POSPaymentBin: Record "POS Payment Bin";
    begin
        if ("Move to Bin Amount" = 0) then begin
          "Move to Bin Code" := '';
          exit;
        end;

        //-NPR5.42 [306858]
        "Move to Bin Reference" := StrSubstNo ('%1 %2', "Payment Method No.", CopyStr (UpperCase(DelChr(Format(CreateGuid),'=','{}-')), 1, 7));

        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        // IF (POSPaymentBin.COUNT() <> 1) THEN
        //  EXIT;

        if POSPaymentBin.IsEmpty () then
          exit;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter ("POS Store Code", '=%1', GetStoreCode ());
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Move to Bin Code", POSPaymentBin."No.");
          exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter ("Attached to POS Unit No.", '=%1', GetPosUnitNo ());
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Move to Bin Code", POSPaymentBin."No.");
          exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter ("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        if (POSPaymentBin.Count () = 1) then begin
          POSPaymentBin.FindFirst ();
          Validate ("Move to Bin Code", POSPaymentBin."No.");
          exit;
        end;

        // POSPaymentBin.FINDFIRST ();
        // VALIDATE ("Move to Bin Code", POSPaymentBin."No.");
        //+NPR5.42 [306858]
    end;

    procedure SetBlindCount(HideFields: Boolean)
    begin

        //-NPR5.49 [348458]
        IsBlindCount := HideFields;
        //+NPR5.49 [348458]
    end;
}

