codeunit 6248398 "NPR PrintAdmitTryPrint"
{
    Access = Internal;
    TableNo = "NPR Print and Admit Buffer";

    trigger OnRun()
    begin
        HandlePrint(Rec);
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
        AttractionWalletPrint: Codeunit "NPR AttractionWallet";
    begin
        if not (PrintandAdmitBuffer.Print and (PrintandAdmitBuffer.Type = PrintandAdmitBuffer.Type::ATTRACTION_WALLET)) then
            exit;

        if AttractionWallet.GetBySystemId(PrintandAdmitBuffer."System Id") then
            AttractionWalletPrint.PrintWallet(AttractionWallet.EntryNo, Enum::"NPR WalletPrintType"::WALLET)
    end;
}