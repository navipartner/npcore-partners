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
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('AdmissionCode', '', AdmissionCode_CptLbl, AdmissionCode_DescLbl);
        WorkflowConfig.AddTextParameter('ScannerId', '', ScannerId_CptLbl, ScannerId_DescLbl);
        WorkflowConfig.AddLabel('ReferenceTitle', ReferenceTitleLbl);
        WorkflowConfig.AddLabel('ReferenceCaption', ReferenceCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'fill_data':
                FrontEnd.WorkflowResponse(FillData(Context));
            'handle_data':
                FrontEnd.WorkflowResponse(HandleData(Context));
        end;
    end;

    local procedure FillData(Context: Codeunit "NPR POS JSON Helper"): JsonArray
    var
        PrintandAdmitBuffer: Record "NPR Print and Admit Buffer";
        PrintandAdmitPublic: Codeunit "NPR Print and Admit Public";
        ReferenceNo: Text;
        NoDataFoundErr: label 'No data found for the reference';
    begin
        ReferenceNo := Context.GetString('reference_input');
        if ReferenceNo <> '' then
            ResolveReferenceNo(ReferenceNo, PrintandAdmitBuffer);
        PrintandAdmitPublic.OnGetDataForReference(ReferenceNo, PrintandAdmitBuffer);
        if PrintandAdmitBuffer.IsEmpty then
            error(NoDataFoundErr);
        exit(BufferTableToJson(PrintandAdmitBuffer));
    end;

    local procedure HandleData(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        PrintandAdmitBuffer: Record "NPR Print and Admit Buffer";
        PrintandAdmitPublic: Codeunit "NPR Print and Admit Public";
        JArray: JsonArray;
    begin
        JArray := Context.GetJToken('buffer_data').AsArray();
        JsonToBufferTable(JArray, PrintandAdmitBuffer);
        ShowData(PrintandAdmitBuffer);
        if PrintandAdmitBuffer.IsEmpty then
            exit;
        PrintandAdmitPublic.OnBeforeHandleBuffer(PrintandAdmitBuffer);
        HandlePrint(PrintandAdmitBuffer);
        HandleAdmit(PrintandAdmitBuffer, Context);
    end;

    local procedure ShowData(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        PrintandAdmit: Page "NPR Print and Admit";
    begin
        PrintandAdmit.SetTable(PrintandAdmitBuffer);
        if not (PrintandAdmit.RunModal() = Action::OK) then
            Error('');
        PrintandAdmit.GetTable(PrintandAdmitBuffer);
    end;

    local procedure ResolveReferenceNo(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        ResolveTicket(ReferenceNo, PrintandAdmitBuffer);
        ResolveMemberCard(ReferenceNo, PrintandAdmitBuffer);
        ResolveWallet(ReferenceNo, PrintandAdmitBuffer);
        ResolveTicketRequest(ReferenceNo, PrintandAdmitBuffer);
    end;

    Internal procedure ResolveTicket(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(Ticket."External Ticket No.") then
            exit;
        Ticket.SetRange("External Ticket No.", UpperCase(ReferenceNo));
        Ticket.SetRange(Blocked, false);
        if Ticket.FindFirst() then
            AddTicketToBuffer(Ticket, PrintandAdmitBuffer);
    end;

    local procedure AddTicketToBuffer(Ticket: Record "NPR TM Ticket"; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        if PrintandAdmitBuffer.Get(PrintandAdmitBuffer.Type::TICKET, Ticket.SystemId) then
            exit;
        PrintandAdmitBuffer.Init();
        PrintandAdmitBuffer.Type := PrintandAdmitBuffer.Type::TICKET;
        PrintandAdmitBuffer."System Id" := Ticket.SystemId;
        PrintandAdmitBuffer."Visual Id" := Ticket."External Ticket No.";
        SetPrintAdmit(Ticket."Item No.", PrintandAdmitBuffer.Print, PrintandAdmitBuffer.Admit);
        PrintandAdmitBuffer.Insert();
    end;

    internal procedure ResolveMemberCard(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(MemberCard."External Card No.") then
            exit;
        MemberCard.SetRange("External Card No.", UpperCase(ReferenceNo));
        MemberCard.SetRange(Blocked, false);
        if MemberCard.FindFirst() then
            AddMemberCardToBuffer(MemberCard, PrintandAdmitBuffer);
    end;

    local procedure AddMemberCardToBuffer(MemberCard: Record "NPR MM Member Card"; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        if PrintandAdmitBuffer.Get(PrintandAdmitBuffer.Type::MEMBER_CARD, MemberCard.SystemId) then
            exit;
        PrintandAdmitBuffer.Init();
        PrintandAdmitBuffer.Type := PrintandAdmitBuffer.Type::MEMBER_CARD;
        PrintandAdmitBuffer."System Id" := MemberCard.SystemId;
        PrintandAdmitBuffer."Visual Id" := MemberCard."External Card No.";
        SetPrintAdmit(FindMembsershipItem(MemberCard), PrintandAdmitBuffer.Print, PrintandAdmitBuffer.Admit);
        PrintandAdmitBuffer.Insert();
    end;

    internal procedure ResolveWallet(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        AttractionWallet: Record "NPR AttractionWallet";
    begin
        if StrLen(ReferenceNo) > MaxStrLen(AttractionWallet.ReferenceNumber) then
            exit;
        AttractionWallet.SetRange(ReferenceNumber, UpperCase(ReferenceNo));
        AttractionWallet.SetFilter(ExpirationDate, '=%1|<=%2', 0DT, CurrentDateTime());
        if not AttractionWallet.FindFirst() then
            exit;
        PrintandAdmitBuffer.Init();
        PrintandAdmitBuffer.Type := PrintandAdmitBuffer.Type::ATTRACTION_WALLET;
        PrintandAdmitBuffer."System Id" := AttractionWallet.SystemId;
        PrintandAdmitBuffer."Visual Id" := AttractionWallet.ReferenceNumber;
        PrintandAdmitBuffer.Print := true;
        PrintandAdmitBuffer.Admit := false;
        PrintandAdmitBuffer.Insert();
    end;

    internal procedure ResolveTicketRequest(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
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
                        AddTicketToBuffer(Ticket, PrintandAdmitBuffer);
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

    local procedure FindMembsershipItem(MemberCard: Record "NPR MM Member Card"): Code[20]
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.SetLoadFields("Item No.");
        MembershipEntry.SetRange("Member Card Entry No.", MemberCard."Entry No.");
        MembershipEntry.SetRange("Membership Entry No.", MemberCard."Membership Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter("Item No.", '<>%1', '');
        if MembershipEntry.FindFirst() then
            exit(MembershipEntry."Item No.");
        MembershipEntry.Reset();
        MembershipEntry.SetRange("Membership Entry No.", MemberCard."Membership Entry No.");
        MembershipEntry.SetFilter(Context, '%1|%2', MembershipEntry.Context::NEW, MembershipEntry.Context::UPGRADE);
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter("Item No.", '<>%1', '');
        if MembershipEntry.FindLast() then
            exit(MembershipEntry."Item No.");
    end;

    local procedure HandlePrint(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        PrintandAdmitBuffer.SetRange(Print, true);
        if PrintandAdmitBuffer.FindSet() then
            repeat
                case PrintandAdmitBuffer.Type of
                    PrintandAdmitBuffer.Type::TICKET:
                        PrintTicket(PrintandAdmitBuffer);
                    PrintandAdmitBuffer.Type::MEMBER_CARD:
                        PrintMemberCard(PrintandAdmitBuffer);
                    PrintandAdmitBuffer.Type::ATTRACTION_WALLET:
                        PrintWallet(PrintandAdmitBuffer);
                end;
            until PrintandAdmitBuffer.Next() = 0;
        PrintandAdmitBuffer.SetRange(Print);
    end;

    local procedure HandleAdmit(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer"; Context: Codeunit "NPR POS JSON Helper")
    var
        AdmissionCode: Code[20];
        ScannerId: Code[10];
    begin
#pragma warning disable AA0139
        AdmissionCode := Context.GetStringParameter('AdmissionCode');
        ScannerId := Context.GetStringParameter('ScannerId');
#pragma warning restore AA0139
        PrintandAdmitBuffer.SetRange(Admit, true);
        if PrintandAdmitBuffer.FindSet() then
            repeat
                case PrintandAdmitBuffer.Type of
                    PrintandAdmitBuffer.Type::TICKET:
                        AdmitTicket(PrintandAdmitBuffer, AdmissionCode, ScannerId);
                    PrintandAdmitBuffer.Type::MEMBER_CARD:
                        AdmitMemberCard(PrintandAdmitBuffer, AdmissionCode, ScannerId);
                    PrintandAdmitBuffer.Type::ATTRACTION_WALLET:
                        AdmitWallet(PrintandAdmitBuffer, AdmissionCode, ScannerId);
                end;
            until PrintandAdmitBuffer.Next() = 0;
        PrintandAdmitBuffer.SetRange(Admit);
    end;

    local procedure PrintTicket(PrintandAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        Ticket: Record "NPR TM Ticket";
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        if not (PrintandAdmitBuffer.Print and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::TICKET)) then
            exit;
        if Ticket.GetBySystemId(PrintandAdmitBuffer."System Id") then
            TMTicketManagement.DoTicketPrint(Ticket);
    end;

    local procedure PrintMemberCard(PrintandAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        MemberCard: Record "NPR MM Member Card";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin
        if not (PrintandAdmitBuffer.Print and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::MEMBER_CARD)) then
            exit;
        if MemberCard.GetBySystemId(PrintandAdmitBuffer."System Id") then
            MemberRetailIntegration.PrintMemberCard(MemberCard."Member Entry No.", MemberCard."Entry No.");
    end;

    local procedure PrintWallet(PrintandAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        AttractionWallet: Record "NPR AttractionWallet";
        WalletMgr: Codeunit "NPR AttractionWallet";
    begin
        if not (PrintandAdmitBuffer.Print and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::ATTRACTION_WALLET)) then
            exit;
        if AttractionWallet.GetBySystemId(PrintandAdmitBuffer."System Id") then
            WalletMgr.PrintWallet(AttractionWallet.EntryNo, Enum::"NPR WalletPrintType"::WALLET);
    end;

    local procedure AdmitTicket(PrintandAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20]; ScannerId: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        if not (PrintandAdmitBuffer.Admit and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::TICKET)) then
            exit;
        if Ticket.GetBySystemId(PrintandAdmitBuffer."System Id") then
            SpeedGate.Admit(SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", AdmissionCode, ScannerId), 1);

    end;

    local procedure AdmitMemberCard(PrintandAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20]; ScannerId: Code[10])
    var
        MemberCard: Record "NPR MM Member Card";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        if not (PrintandAdmitBuffer.Admit and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::MEMBER_CARD)) then
            exit;
        if MemberCard.GetBySystemId(PrintandAdmitBuffer."System Id") then
            SpeedGate.Admit(SpeedGate.CreateAdmitToken(MemberCard."External Card No.", AdmissionCode, ScannerId), 1);
    end;

    local procedure AdmitWallet(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer"; AdmissionCode: Code[20]; ScannerId: Code[10])
    var
        AttractionWallet: Record "NPR AttractionWallet";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        if not (PrintandAdmitBuffer.Admit and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::ATTRACTION_WALLET)) then
            exit;
        if attractionWallet.GetBySystemId(PrintandAdmitBuffer."System Id") then
            SpeedGate.Admit(SpeedGate.CreateAdmitToken(AttractionWallet.ReferenceNumber, AdmissionCode, ScannerId), 1);
    end;

    local procedure BufferTableToJson(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer") Array: JsonArray

    begin
        if PrintandAdmitBuffer.FindSet() then
            repeat
                Array.Add(RecordToJson(PrintandAdmitBuffer));
            until PrintandAdmitBuffer.Next() = 0;
        exit(Array);
    end;

    local procedure RecordToJson(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer"): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('type', PrintandAdmitBuffer.Type);
        JObject.Add('system_id', PrintandAdmitBuffer."System Id");
        JObject.Add('visual_id', PrintandAdmitBuffer."Visual Id");
        JObject.Add('admit', PrintandAdmitBuffer.Admit);
        JObject.Add('print', PrintandAdmitBuffer.Print);
        exit(JObject);
    end;

    local procedure JsonToBufferTable(JArray: JsonArray; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        JsonRecord: JsonToken;
    begin
        foreach JsonRecord in JArray do begin
            PrintandAdmitBuffer.Init();
            PrintandAdmitBuffer.Type := JsonHelper.GetJInteger(JsonRecord, 'type', false);
            PrintandAdmitBuffer."System Id" := JsonHelper.GetJText(JsonRecord, 'system_id', true);
#pragma warning disable AA0139
            PrintandAdmitBuffer."Visual Id" := JsonHelper.GetJText(JsonRecord, 'visual_id', true);
#pragma warning restore AA0139
            PrintandAdmitBuffer.Admit := JsonHelper.GetJBoolean(JsonRecord, 'admit', true);
            PrintandAdmitBuffer.Print := JsonHelper.GetJBoolean(JsonRecord, 'print', true);
            PrintandAdmitBuffer.Insert();
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionPrintandAdmit.js###
        'const main=async({workflow:e,parameters:i,popup:n,context:a,captions:t})=>{if(a.reference_input=await n.input({title:t.ReferenceTitle,caption:t.ReferenceCaption}),a.reference_input==null)return" ";let r=await e.respond("fill_data");await e.respond("handle_data",{buffer_data:r})};'
        );
    end;
}
