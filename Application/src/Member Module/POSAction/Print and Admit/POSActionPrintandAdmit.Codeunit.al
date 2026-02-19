codeunit 6150688 "NPR POS Action Print and Admit" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action handles print and admit for a Reference No.';
        AdmissionCode_CptLbl: Label 'Admission Code';
        AdmissionCode_DescLbl: Label 'Specifies the fixed Admission Code to be used for the action';
        ScannerId_CptLbl: Label 'Scanner Id';
        ScannerId_DescLbl: Label 'Specifies the fixed Scanner Id to be used for the action';
        ReferenceCaptionLbl: Label 'Enter Reference No.';
        ReferenceTitleLbl: Label 'Print & Admit by reference';
        ReferenceInputLbl: Label 'Reference Input';
        ShowDataLbl: Label 'Show Data';
        ShowDataDescLbl: Label 'Shows the data that is going to be printed and/or admitted';
        WelcomeMsgLbl: Label 'Welcome';
        PrintFailedErrLbl: Label 'Printing of one or more references did not succeed.';
        QtyToAdmitLbl: Label 'Quantity to Admit';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('AdmissionCode', '', AdmissionCode_CptLbl, AdmissionCode_DescLbl);
        WorkflowConfig.AddTextParameter('ScannerId', '', ScannerId_CptLbl, ScannerId_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowData', false, ShowDataLbl, ShowDataDescLbl);
        WorkflowConfig.AddTextParameter('reference_input', '', ReferenceInputLbl, ReferenceInputLbl);
        WorkflowConfig.AddLabel('ReferenceTitle', ReferenceTitleLbl);
        WorkflowConfig.AddLabel('ReferenceCaption', ReferenceCaptionLbl);
        WorkflowConfig.AddLabel('welcomeMsg', WelcomeMsgLbl);
        WorkflowConfig.AddLabel('printingFailed', PrintFailedErrLbl);
        WorkflowConfig.AddLabel('QuantityAdmitLbl', QtyToAdmitLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'fill_data':
                FrontEnd.WorkflowResponse(FillData(Context));
            'try_admit':
                FrontEnd.WorkflowResponse(HandleTryAdmit(Context, Setup.GetPOSUnitNo()));
            'handle_admit_print':
                FrontEnd.WorkflowResponse(HandlePrintAndAdmit(Context));
        end;
    end;

    local procedure FillData(Context: Codeunit "NPR POS JSON Helper"): JsonArray
    var
        PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer";
        PrintAndAdmitPublic: Codeunit "NPR Print and Admit Public";
        ReferenceNo: Text;
        AdmissionCode: Code[20];
        ShowDataPrintAdmit: Boolean;
        NoDataFoundErr: Label 'No data found for the reference';
    begin
        AdmissionCode := CopyStr(Context.GetStringParameter('AdmissionCode'), 1, MaxStrLen(AdmissionCode));

        ReferenceNo := Context.GetString('reference_input');
        if (ReferenceNo <> '') then
            ResolveReferenceNo(ReferenceNo, PrintAndAdmitBuffer, AdmissionCode);

        PrintAndAdmitPublic.OnGetDataForReference(ReferenceNo, PrintAndAdmitBuffer);

        if (PrintAndAdmitBuffer.IsEmpty()) then
            error(NoDataFoundErr);

        ShowDataPrintAdmit := Context.GetBooleanParameter('ShowData');
        if ShowDataPrintAdmit then
            ShowData(PrintAndAdmitBuffer);

        if (PrintAndAdmitBuffer.IsEmpty()) then
            exit;

        PrintAndAdmitPublic.OnBeforeHandleBuffer(PrintAndAdmitBuffer);
        exit(BufferTableToJson(PrintAndAdmitBuffer));
    end;

    local procedure HandleTryAdmit(Context: Codeunit "NPR POS JSON Helper"; POSUnitNo: Code[10]) Response: JsonObject
    var
        PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer";
        JArray: JsonArray;
        TryAdmitArray: JsonArray;
        UnconfirmedGroup: Boolean;
        DefaultQtyGroupUnconfirmedArray: JsonArray;
    begin
        JArray := Context.GetJToken('buffer_data').AsArray();
        JsonToBufferTable(JArray, PrintAndAdmitBuffer);

        TryAdmit(PrintAndAdmitBuffer, Context, POSUnitNo, UnconfirmedGroup, DefaultQtyGroupUnconfirmedArray, TryAdmitArray);

        Response.Add('unconfirmedGroup', UnconfirmedGroup);
        Response.Add('defaultQuantityUnconfirmed', DefaultQtyGroupUnconfirmedArray);
        Response.Add('tokens', TryAdmitArray);
    end;

    local procedure TryAdmit(var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; Context: Codeunit "NPR POS JSON Helper"; POSUnitNo: Code[10]; var UnconfirmedGroup: Boolean; var DefaultQtyGroupUnconfirmed: JsonArray; var TryAdmitArray: JsonArray)
    var
        AdmissionCode: Code[20];
        ScannerId: Code[10];
    begin
        AdmissionCode := CopyStr(Context.GetStringParameter('AdmissionCode'), 1, MaxStrLen(AdmissionCode));
        ScannerId := CopyStr(Context.GetStringParameter('ScannerId'), 1, MaxStrLen(ScannerId));
        if (ScannerId = '') then
            ScannerId := POSUnitNo;

        PrintAndAdmitBuffer.SetRange(Admit, true);
        if (PrintAndAdmitBuffer.FindSet()) then
            repeat
                case PrintAndAdmitBuffer.Type of
                    PrintAndAdmitBuffer.Type::TICKET:
                        TryAdmitTicket(PrintAndAdmitBuffer, AdmissionCode, ScannerId, UnconfirmedGroup, DefaultQtyGroupUnconfirmed, TryAdmitArray);

                    PrintAndAdmitBuffer.Type::MEMBER_CARD:
                        TryAdmitMemberCard(PrintAndAdmitBuffer, AdmissionCode, ScannerId, TryAdmitArray);

                    PrintAndAdmitBuffer.Type::ATTRACTION_WALLET:
                        TryAdmitWallet(PrintAndAdmitBuffer, AdmissionCode, ScannerId, UnconfirmedGroup, DefaultQtyGroupUnconfirmed, TryAdmitArray);
                end;
            until (PrintAndAdmitBuffer.Next() = 0);

        PrintAndAdmitBuffer.SetRange(Admit);
    end;

    local procedure HandlePrintAndAdmit(Context: Codeunit "NPR POS JSON Helper") WorkflowResponse: JsonObject
    var
        PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer";
        JArray: JsonArray;
        JObject: JsonObject;
        AdmittedReferences: JsonArray;
        TryPrint: Codeunit "NPR PrintAdmitTryPrint";
        PrintSuccessful: Boolean;
        JTok: JsonToken;
    begin
        JObject := Context.GetJToken('admit_data').AsObject();
        if JObject.Get('tokens', JTok) then
            JArray := JTok.AsArray();

        HandleAdmit(JArray, Context, AdmittedReferences);
        WorkflowResponse.Add('admittedReferences', AdmittedReferences);

        // Regardless of what might happen with the print we want to commit the admits
        Commit();

        Clear(JArray);
        JArray := Context.GetJToken('buffer_data').AsArray();
        JsonToBufferTable(JArray, PrintAndAdmitBuffer);
        PrintSuccessful := TryPrint.Run(PrintAndAdmitBuffer);
        WorkflowResponse.Add('printSuccessful', PrintSuccessful);
        if (not PrintSuccessful) then
            WorkflowResponse.Add('printErrorMsg', GetLastErrorText());
    end;

    local procedure ShowData(var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        PrintAndAdmit: Page "NPR Print and Admit";
    begin
        PrintAndAdmit.SetTable(PrintAndAdmitBuffer);
        if not (PrintAndAdmit.RunModal() = Action::OK) then
            Error('');
        PrintAndAdmit.GetTable(PrintAndAdmitBuffer);
    end;

    local procedure ResolveReferenceNo(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary; AdmissionCode: Code[20])
    begin
        ResolveTicket(ReferenceNo, PrintAndAdmitBuffer);
        ResolveMemberCard(ReferenceNo, PrintAndAdmitBuffer);
        ResolveWallet(ReferenceNo, PrintAndAdmitBuffer, AdmissionCode);
        ResolveTicketRequest(ReferenceNo, PrintAndAdmitBuffer);
    end;

    Internal procedure ResolveTicket(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(Ticket."External Ticket No.") then
            exit;
        Ticket.SetRange("External Ticket No.", UpperCase(ReferenceNo));
        Ticket.SetRange(Blocked, false);
        if Ticket.FindFirst() then
            AddTicketToBuffer(Ticket, PrintAndAdmitBuffer);
    end;

    local procedure AddTicketToBuffer(Ticket: Record "NPR TM Ticket"; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        if PrintAndAdmitBuffer.Get(PrintAndAdmitBuffer.Type::TICKET, Ticket.SystemId) then
            exit;
        PrintAndAdmitBuffer.Init();
        PrintAndAdmitBuffer.Type := PrintAndAdmitBuffer.Type::TICKET;
        PrintAndAdmitBuffer."System Id" := Ticket.SystemId;
        PrintAndAdmitBuffer."Visual Id" := Ticket."External Ticket No.";
        SetPrintAdmit(Ticket."Item No.", PrintAndAdmitBuffer.Print, PrintAndAdmitBuffer.Admit);
        PrintAndAdmitBuffer.Insert();
    end;

    internal procedure ResolveMemberCard(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(MemberCard."External Card No.") then
            exit;
        MemberCard.SetRange("External Card No.", UpperCase(ReferenceNo));
        MemberCard.SetRange(Blocked, false);
        if MemberCard.FindFirst() then
            AddMemberCardToBuffer(MemberCard, PrintAndAdmitBuffer);
    end;

    local procedure AddMemberCardToBuffer(MemberCard: Record "NPR MM Member Card"; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        if PrintAndAdmitBuffer.Get(PrintAndAdmitBuffer.Type::MEMBER_CARD, MemberCard.SystemId) then
            exit;
        PrintAndAdmitBuffer.Init();
        PrintAndAdmitBuffer.Type := PrintAndAdmitBuffer.Type::MEMBER_CARD;
        PrintAndAdmitBuffer."System Id" := MemberCard.SystemId;
        PrintAndAdmitBuffer."Visual Id" := MemberCard."External Card No.";
        SetPrintAdmit(FindMembershipItem(MemberCard), PrintAndAdmitBuffer.Print, PrintAndAdmitBuffer.Admit);
        PrintAndAdmitBuffer.Insert();
    end;

    internal procedure ResolveWallet(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary; AdmissionCode: Code[20])
    var
        AttractionWallet: Record "NPR AttractionWallet";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        FilterSet: Boolean;
    begin
        if (StrLen(ReferenceNo) > MaxStrLen(WalletExternalReference.ExternalReference)) and (StrLen(ReferenceNo) > MaxStrLen(AttractionWallet.ReferenceNumber)) then
            exit;
        if (StrLen(ReferenceNo) <= MaxStrLen(WalletExternalReference.ExternalReference)) then begin
            WalletExternalReference.SetLoadFields(WalletEntryNo);
            WalletExternalReference.SetRange(ExternalReference, ReferenceNo);
            WalletExternalReference.SetFilter(BlockedAt, '=%1', 0DT);
            WalletExternalReference.SetFilter(ExpiresAt, '>%1|=%2', CurrentDateTime(), 0DT);
            if (WalletExternalReference.FindFirst()) then begin
                AttractionWallet.SetRange(EntryNo, WalletExternalReference.WalletEntryNo);
                FilterSet := true;
            end;
        end;

        if (StrLen(ReferenceNo) <= MaxStrLen(AttractionWallet.ReferenceNumber)) and (not FilterSet) then begin
            AttractionWallet.SetCurrentKey(ReferenceNumber);
            AttractionWallet.SetRange(ReferenceNumber, UpperCase(ReferenceNo));
            FilterSet := true;
        end;

        if (not FilterSet) then
            exit;

        AttractionWallet.SetFilter(ExpirationDate, '=%1|<=%2', 0DT, CurrentDateTime());
        if not AttractionWallet.FindFirst() then
            exit;

        AddWalletAssetLinesToBuffer(AttractionWallet, PrintAndAdmitBuffer, AdmissionCode);
    end;

    internal procedure ResolveWallet(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        AttractionWallet: Record "NPR AttractionWallet";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(AttractionWallet.ReferenceNumber) then
            exit;
        AttractionWallet.SetRange(ReferenceNumber, UpperCase(ReferenceNo));
        AttractionWallet.SetFilter(ExpirationDate, '=%1|<=%2', 0DT, CurrentDateTime());
        if not AttractionWallet.FindFirst() then
            exit;

        AddWalletAssetLinesToBuffer(AttractionWallet, PrintAndAdmitBuffer, '');
    end;

    local procedure AddWalletAssetLinesToBuffer(AttractionWallet: Record "NPR AttractionWallet"; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary; AdmissionCode: Code[20])
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
        Ticket: Record "NPR TM Ticket";
        WalletAgent: Codeunit "NPR AttractionWallet";
        SGSpeedGate: Codeunit "NPR SG SpeedGate";
        AdmitToCodes: List of [Code[20]];
        TicketId: Guid;
        ProfileLineId: Guid;
        ReferenceNumberIdentified: Boolean;
    begin
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(AttractionWallet.EntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', Enum::"NPR WalletLineType"::Ticket);
        if (not WalletAssetLine.FindSet()) then
            exit;
        repeat
            if (SGSpeedGate.CheckForTicket('', WalletAssetLine.LineTypeReference, AdmissionCode, TicketId, AdmitToCodes, ProfileLineId, ReferenceNumberIdentified)) then
                if not PrintAndAdmitBuffer.Get(PrintAndAdmitBuffer.Type::ATTRACTION_WALLET, WalletAssetLine.LineTypeSystemId) then begin
                    PrintAndAdmitBuffer.Init();
                    PrintAndAdmitBuffer.Type := PrintAndAdmitBuffer.Type::ATTRACTION_WALLET;
                    PrintAndAdmitBuffer."System Id" := WalletAssetLine.LineTypeSystemId;
                    Ticket.GetBySystemId(WalletAssetLine.LineTypeSystemId);
                    PrintAndAdmitBuffer."Visual Id" := Ticket."External Ticket No.";
                    SetPrintAdmit(Ticket."Item No.", PrintAndAdmitBuffer.Print, PrintAndAdmitBuffer.Admit);
                    PrintAndAdmitBuffer.Print := false;
                    PrintAndAdmitBuffer.Insert();
                end;
        until (WalletAssetLine.Next() = 0);

        PrintAndAdmitBuffer.Init();
        PrintAndAdmitBuffer.Type := PrintAndAdmitBuffer.Type::ATTRACTION_WALLET;
        PrintAndAdmitBuffer."System Id" := AttractionWallet.SystemId;
        PrintAndAdmitBuffer."Visual Id" := AttractionWallet.ReferenceNumber;
        PrintAndAdmitBuffer.Print := true;
        PrintAndAdmitBuffer.Admit := false;
        PrintAndAdmitBuffer.Insert();
    end;

    internal procedure ResolveTicketRequest(ReferenceNo: Text; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";

    begin
        if StrLen(ReferenceNo) > MaxStrLen(TicketReservationRequest."Session Token ID") then
            exit;
        TicketReservationRequest.SetRange("Session Token ID", ReferenceNo);
        if (TicketReservationRequest.FindSet()) then
            repeat
                Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        AddTicketToBuffer(Ticket, PrintAndAdmitBuffer);
                    until (Ticket.Next() = 0);
            until (TicketReservationRequest.Next() = 0);
    end;

    local procedure SetPrintAdmit(ItemNo: Code[20]; var Print: Boolean; var Admit: Boolean)
    var
        Item: Record Item;
    begin
        if ItemNo = '' then
            exit;
        Item.SetLoadFields("NPR POS Admit Action");
        if not Item.Get(ItemNo) then
            exit;
        Print := Item."NPR POS Admit Action" in ["NPR TM POS Admit Action"::PRINT, "NPR TM POS Admit Action"::PRINT_ADMIT];
        Admit := Item."NPR POS Admit Action" in ["NPR TM POS Admit Action"::ADMIT, "NPR TM POS Admit Action"::PRINT_ADMIT];
    end;

    local procedure FindMembershipItem(MemberCard: Record "NPR MM Member Card"): Code[20]
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        // Find the item that created membership and use that to determine the print and admit behavior. 
        // We are throwing this to the speedgate to figure out validity and admit logic
        MembershipEntry.SetLoadFields("Item No.");
        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
        MembershipEntry.SetFilter(Context, '=%1|=%2', MembershipEntry.Context::NEW, MembershipEntry.Context::UPGRADE);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        if (MembershipEntry.FindLast()) then
            exit(MembershipEntry."Item No.");

        MembershipEntry.Reset();
        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetLoadFields("Item No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
        MembershipEntry.SetFilter("Original Context", '=%1', MembershipEntry.Context::NEW);
        if (MembershipEntry.FindFirst()) then
            exit(MembershipEntry."Item No.");

        // Silently fail if we can't find an item for the membership (this would be a really messed up membership)
        // which means the member won't get printed or admitted through this action, but action will still succeed for other valid references
        exit('');
    end;

    local procedure HandleAdmit(JTokensArray: JsonArray; Context: Codeunit "NPR POS JSON Helper"; var AdmittedReferences: JsonArray)
    var
        DummyTicket: Record "NPR TM Ticket";
        DummyMemberCard: Record "NPR MM Member Card";
        DummyWallet: Record "NPR AttractionWallet";
        JsonHelper: Codeunit "NPR Json Helper";
        AdmittedReference, MemberDetails : JsonObject;
        TableCaption: Text;
        Type, QuantityToAdmit, QtyToAdmitUnconfirmedGroup : Integer;
        Token, SystemId, TokenUnconfirmedGroup : Guid;
        QtyUnconfirmedTok, QtyToken, JToken : JsonToken;
        QtyUnconfirmedArray: JsonArray;
        VisualId: Text[250];
    begin
        QtyUnconfirmedTok := Context.GetJToken('quantityToAdmUnconfirmedGroup');
        QtyUnconfirmedArray := QtyUnconfirmedTok.AsArray();

        foreach JToken in JTokensArray do begin
            Type := JsonHelper.GetJInteger(JToken, 'type', false);
            Token := JsonHelper.GetJText(JToken, 'token', false);
            SystemId := JsonHelper.GetJText(JToken, 'systemId', false);
            VisualId := CopyStr(JsonHelper.GetJText(JToken, 'visualId', false), 1, MaxStrLen(VisualId));
            QuantityToAdmit := JsonHelper.GetJInteger(JToken, 'quantityToAdmit', false);

            foreach QtyToken in QtyUnconfirmedArray do begin
                TokenUnconfirmedGroup := JsonHelper.GetJText(QtyToken, 'token', false);
                QtyToAdmitUnconfirmedGroup := JsonHelper.GetJInteger(QtyToken, 'qtytoAdmit', false);
                if TokenUnconfirmedGroup = Token then
                    QuantityToAdmit := QtyToAdmitUnconfirmedGroup
            end;

            if QuantityToAdmit < 1 then
                QuantityToAdmit := 1;

            case
                Type of
                0: //Ticket
                    begin
                        AdmitTicket(Token, SystemId, QuantityToAdmit);
                        TableCaption := DummyTicket.TableCaption();
                    end;
                1: //Member Card
                    begin
                        AdmitMemberCard(Token, SystemId, MemberDetails);
                        TableCaption := DummyMemberCard.TableCaption();
                    end;
                2: //AttractionWallet
                    begin
                        AdmitWallet(Token, SystemId);
                        TableCaption := DummyWallet.TableCaption();
                    end;
            end;

            Clear(AdmittedReference);
            AdmittedReference.Add('type', Type);
            AdmittedReference.Add('tableCaption', TableCaption);
            AdmittedReference.Add('referenceId', VisualId);

            if (Type = 1) then
                AdmittedReference.Add('memberDetails', MemberDetails);

            AdmittedReferences.Add(AdmittedReference);
        end;
    end;

    local procedure TryAdmitTicket(PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20];
                                    ScannerId: Code[10]; var UnconfirmedGroup: Boolean; var DefaultQtyGroupUnconfirmed: JsonArray;
                                     var TryAdmitArray: JsonArray)
    var
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        HaveError: Boolean;
        ErrorMessage: Text;
        AdmitToken: Guid;
    begin
        if not (PrintAndAdmitBuffer.Admit and (PrintAndAdmitBuffer.Type = PrintAndAdmitBuffer.Type::TICKET)) then
            exit;
        if Ticket.GetBySystemId(PrintAndAdmitBuffer."System Id") then begin
            AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", AdmissionCode, ScannerId, false, HaveError, ErrorMessage);

            CheckGroupTicket(PrintAndAdmitBuffer, AdmitToken, UnconfirmedGroup, DefaultQtyGroupUnconfirmed, TryAdmitArray);
        end;
    end;

    local procedure CheckGroupTicket(PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmitToken: Guid; var UnconfirmedGroup: Boolean;
                                     var DefaultQtyGroupUnconfirmed: JsonArray; var TryAdmitArray: JsonArray)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        BlankGuid: Guid;
        AdmitCount, GroupQuantity : Integer;
        IsGroup: Boolean;
        ConfirmedGroup: Boolean;
    begin
        if AdmitToken <> BlankGuid then begin
            ValidationRequest.SetCurrentKey(Token);
            ValidationRequest.SetFilter(Token, '=%1', AdmitToken);
            if ValidationRequest.FindFirst() then
                if (Ticket.GetBySystemId(ValidationRequest.EntityId)) then begin
                    AccessEntry.SetCurrentKey("Ticket No.");
                    AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    AccessEntry.SetFilter("Admission Code", '=%1', ValidationRequest.AdmissionCode);
                    if AccessEntry.FindFirst() then begin
                        DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
                        DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::ADMITTED);
                        DetAccessEntry.SetFilter(Quantity, '>%1', 0);
                        AdmitCount := DetAccessEntry.Count;
                        GroupQuantity := AccessEntry.Quantity;
                        if (GroupQuantity > 1) then begin
                            IsGroup := true;
                            if (AdmitCount > 0) then
                                ConfirmedGroup := true
                            else
                                UnconfirmedGroup := true;
                        end;
                    end;
                end;

            BuildArrays(PrintAndAdmitBuffer, DefaultQtyGroupUnconfirmed, TryAdmitArray, AdmitToken, IsGroup, ConfirmedGroup, ValidationRequest.SuggestedQuantity);
        end;
    end;

    local procedure BuildArrays(PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; var DefaultQtyGroupUnconfirmed: JsonArray;
                                 var TryAdmitArray: JsonArray; AdmitToken: Guid; IsGroup: Boolean; ConfirmedGroup: Boolean; SuggestedQty: Integer)
    var
        TryAdmitObj, DefaultQtyObject : JsonObject;
    begin
        Clear(TryAdmitObj);
        TryAdmitObj.Add('token', AdmitToken);
        if IsGroup then begin
            if ConfirmedGroup then
                TryAdmitObj.Add('quantityToAdmit', SuggestedQty)
            else begin
                TryAdmitObj.Add('quantityToAdmit', -1);
                Clear(DefaultQtyObject);
                DefaultQtyObject.Add('token', AdmitToken);
                DefaultQtyObject.Add('defaultQuantity', SuggestedQty);
                DefaultQtyGroupUnconfirmed.Add(DefaultQtyObject);
            end;
        end else
            TryAdmitObj.Add('quantityToAdmit', 1);

        TryAdmitObj.Add('type', 0);
        TryAdmitObj.Add('visualId', PrintAndAdmitBuffer."Visual Id");
        TryAdmitObj.Add('systemId', PrintAndAdmitBuffer."System Id");
        TryAdmitArray.Add(TryAdmitObj);
    end;

    local procedure TryAdmitMemberCard(PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20]; ScannerId: Code[10]; var TryAdmitArray: JsonArray)
    var
        MemberCard: Record "NPR MM Member Card";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        TryAdmitObj: JsonObject;
        HaveError: Boolean;
        ErrorMessage: Text;
        AdmitToken: Guid;
        PrintAdmitType: Integer;
    begin
        if not (PrintAndAdmitBuffer.Admit and (PrintAndAdmitBuffer.Type = PrintAndAdmitBuffer.Type::MEMBER_CARD)) then
            exit;

        MemberCard.SetLoadFields("Entry No.", "External Card No.");
        if (not MemberCard.GetBySystemId(PrintAndAdmitBuffer."System Id")) then
            exit;

        AdmitToken := SpeedGate.CreateAdmitToken(MemberCard."External Card No.", AdmissionCode, ScannerId, false, HaveError, ErrorMessage);
        if not HaveError then begin
            Clear(TryAdmitObj);
            TryAdmitObj.Add('token', AdmitToken);
            TryAdmitObj.Add('quantityToAdmit', 1);
            PrintAdmitType := PrintAndAdmitBuffer.Type;
            TryAdmitObj.Add('type', PrintAdmitType);
            TryAdmitObj.Add('visualId', PrintAndAdmitBuffer."Visual Id");
            TryAdmitObj.Add('systemId', PrintAndAdmitBuffer."System Id");
            TryAdmitArray.Add(TryAdmitObj);
        end else begin
            Commit();  //log transaction in speedgate log entry
            Error(ErrorMessage);
        end;
    end;

    local procedure TryAdmitWallet(var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20];
                                    ScannerId: Code[10]; var UnconfirmedGroup: Boolean; var DefaultQtyGroupUnconfirmed: JsonArray;
                                   var TryAdmitArray: JsonArray)
    var
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        HaveError: Boolean;
        ErrorMessage: Text;
        AdmitToken: Guid;
    begin
        if not (PrintAndAdmitBuffer.Admit and (PrintAndAdmitBuffer.Type = PrintAndAdmitBuffer.Type::ATTRACTION_WALLET)) then
            exit;
        if Ticket.GetBySystemId(PrintAndAdmitBuffer."System Id") then begin
            AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", AdmissionCode, ScannerId, false, HaveError, ErrorMessage);
            CheckGroupTicket(PrintAndAdmitBuffer, AdmitToken, UnconfirmedGroup, DefaultQtyGroupUnconfirmed, TryAdmitArray);
        end;
    end;

    local procedure AdmitTicket(Token: Guid; SystemId: Guid; QuantityToAdmit: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        if Ticket.GetBySystemId(SystemId) then
            SpeedGate.Admit(Token, QuantityToAdmit);
    end;

    local procedure AdmitMemberCard(Token: Guid; SystemId: Guid; var AdmittedMemberDetails: JsonObject)
    var
        MemberCard: Record "NPR MM Member Card";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        POSActionMemberArrival: Codeunit "NPR POS Action: MM Member ArrB";
    begin
        Clear(AdmittedMemberDetails);

        MemberCard.SetLoadFields("Entry No.", "External Card No.");
        if (not MemberCard.GetBySystemId(SystemId)) then
            exit;

        SpeedGate.Admit(Token, 1);
        POSActionMemberArrival.AddToastMemberScannedData(MemberCard."Entry No.", 0, AdmittedMemberDetails);
    end;

    local procedure AdmitWallet(Token: Guid; SystemId: Guid)
    var
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        if Ticket.GetBySystemId(SystemId) then
            SpeedGate.Admit(Token, 1);
    end;

    local procedure BufferTableToJson(var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer") Array: JsonArray

    begin
        if PrintAndAdmitBuffer.FindSet() then
            repeat
                Array.Add(RecordToJson(PrintAndAdmitBuffer));
            until PrintAndAdmitBuffer.Next() = 0;
        exit(Array);
    end;

    local procedure RecordToJson(var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer"): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('type', PrintAndAdmitBuffer.Type);
        JObject.Add('system_id', PrintAndAdmitBuffer."System Id");
        JObject.Add('visual_id', PrintAndAdmitBuffer."Visual Id");
        JObject.Add('admit', PrintAndAdmitBuffer.Admit);
        JObject.Add('print', PrintAndAdmitBuffer.Print);
        exit(JObject);
    end;

    local procedure JsonToBufferTable(JArray: JsonArray; var PrintAndAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        JsonRecord: JsonToken;
    begin
        foreach JsonRecord in JArray do begin
            PrintAndAdmitBuffer.Init();
            PrintAndAdmitBuffer.Type := JsonHelper.GetJInteger(JsonRecord, 'type', false);
            PrintAndAdmitBuffer."System Id" := JsonHelper.GetJText(JsonRecord, 'system_id', true);
#pragma warning disable AA0139
            PrintAndAdmitBuffer."Visual Id" := JsonHelper.GetJText(JsonRecord, 'visual_id', true);
#pragma warning restore AA0139
            PrintAndAdmitBuffer.Admit := JsonHelper.GetJBoolean(JsonRecord, 'admit', true);
            PrintAndAdmitBuffer.Print := JsonHelper.GetJBoolean(JsonRecord, 'print', true);
            PrintAndAdmitBuffer.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Text000Lbl: Label 'Print and Admit';
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := ActionCode();
            EanBoxEvent."Module Name" := CopyStr(Text000Lbl, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text000Lbl, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            ActionCode():
                Sender.SetNonEditableParameterValues(EanBoxEvent, 'reference_input', true, '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, false)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;

        if RecordFound(EanBoxValue) then
            InScope := true;
    end;

    local procedure RecordFound(ReferenceNo: Text): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
        AttractionWallet: Record "NPR AttractionWallet";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        MemberCard.SetRange("External Card No.", CopyStr(ReferenceNo, 1, MaxStrLen(MemberCard."External Card No.")));
        if not MemberCard.IsEmpty() then
            exit(true);

        Ticket.SetRange("External Ticket No.", CopyStr(ReferenceNo, 1, MaxStrLen(Ticket."External Ticket No.")));
        if not Ticket.IsEmpty() then
            exit(true);

        WalletExternalReference.SetRange(ExternalReference, ReferenceNo);
        if (not WalletExternalReference.IsEmpty()) then
            exit(true);

        AttractionWallet.SetRange(ReferenceNumber, CopyStr(ReferenceNo, 1, MaxStrLen(AttractionWallet.ReferenceNumber)));
        if not AttractionWallet.IsEmpty() then
            exit(true);

        TicketReservationRequest.SetRange("Session Token ID", CopyStr(ReferenceNo, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
        if not TicketReservationRequest.IsEmpty then
            exit(true);

        exit(false);
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::TM_PRINT_AND_ADMIT));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POS Action Print and Admit");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionPrintandAdmit.js###
        'const main=async({workflow:m,parameters:l,popup:r,context:i,captions:t,toast:u})=>{if(l.reference_input)i.reference_input=l.reference_input;else if(i.reference_input=await r.input({title:t.ReferenceTitle,caption:t.ReferenceCaption}),i.reference_input===null)return;const a=await m.respond("fill_data");if(!a||a.length===0)return;const d=await m.respond("try_admit",{buffer_data:a});if(d.unconfirmedGroup){const e=d.defaultQuantityUnconfirmed;i.quantityToAdmUnconfirmedGroup=[];for(const s of e){const o=await r.numpad({caption:t.QuantityAdmitLbl,title:t.QuantityAdmitLbl,value:s.defaultQuantity});i.quantityToAdmUnconfirmedGroup.push({token:s.token,qtytoAdmit:o})}}else i.quantityToAdmUnconfirmedGroup=[];const n=await m.respond("handle_admit_print",{admit_data:d,buffer_data:a});n.admittedReferences&&n.admittedReferences.forEach(e=>{switch(e.type){case 1:{e.memberDetails.MemberScanned&&u.memberScanned({memberImg:e.memberDetails.MemberScanned.ImageDataUrl,memberName:e.memberDetails.MemberScanned.Name,validForAdmission:e.memberDetails.MemberScanned.Valid,memberExpiry:e.memberDetails.MemberScanned.ExpiryDate,content:[{caption:e.memberDetails.MemberScanned.MembershipCodeCaption,value:e.memberDetails.MemberScanned.MembershipCodeDescription}]});break}default:{u.success(`${t.welcomeMsg} ${e.tableCaption} ${e.referenceId}`,{title:t.welcomeMsg});break}}}),n.printSuccessful||await r.error(`${t.printingFailed} ${n.printErrorMsg}`)};'
        );
    end;
}