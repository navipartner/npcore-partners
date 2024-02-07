report 6014520 "NPR Update Modified Date"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Update Modified Date for PowerBI';
    DataAccessIntent = ReadWrite;
    ProcessingOnly = true;
    Permissions =
     tabledata "NPR TM Det. Ticket AccessEntry" = rm,
     tabledata "G/L Entry" = rm,
     tabledata "Item Ledger Entry" = rm,
     tabledata "NPR MM Loy. LedgerEntry (Srvr)" = rm,
     tabledata "NPR MM Membership Entry" = rm,
     tabledata "NPR POS Entry" = rm,
     tabledata "NPR POS Entry Sales Line" = rm,
     tabledata "NPR POS Entry Tax Line" = rm,
     tabledata "NPR TM Admis. Schedule Entry" = rm,
     tabledata "NPR TM Admis. Schedule Lines" = rm,
     tabledata "NPR TM Ticket Access Entry" = rm,
     tabledata "Value Entry" = rm,
     tabledata "Vendor Ledger Entry" = rm,
     tabledata "NPR TM Ticket Access Stats" = rm;

    dataset
    {
        dataitem("NPR TM Det. Ticket AccessEntry"; "NPR TM Det. Ticket AccessEntry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Open(ProgressLbl);
                    Dialog.Update(1, 1);
                    Dialog.Update(3, "NPR TM Det. Ticket AccessEntry".Count());
                    Dialog.Update(4, "NPR TM Det. Ticket AccessEntry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Sales Channel No." = '' then begin
                    "Sales Channel No." += ' ';
                    Modify();
                    "Sales Channel No." := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Sales Channel No.", 1, 1);
                    "Sales Channel No." := CopyStr("Sales Channel No.", 2, MaxStrLen("Sales Channel No."));
                    Modify();
                    "Sales Channel No." := CopyStr(OneChar + "Sales Channel No.", 1, MaxStrLen("Sales Channel No."));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("G/L Entry"; "G/L Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 2);
                    Dialog.Update(3, "G/L Entry".Count());
                    Dialog.Update(4, "G/L Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 3);
                    Dialog.Update(3, "Item Ledger Entry".Count());
                    Dialog.Update(4, "Item Ledger Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR MM Loy. LedgerEntry (Srvr)"; "NPR MM Loy. LedgerEntry (Srvr)")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 4);
                    Dialog.Update(3, "NPR MM Loy. LedgerEntry (Srvr)".Count());
                    Dialog.Update(4, "NPR MM Loy. LedgerEntry (Srvr)".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Reference Number" = '' then begin
                    "Reference Number" += ' ';
                    Modify();
                    "Reference Number" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Reference Number", 1, 1);
                    "Reference Number" := CopyStr("Reference Number", 2, MaxStrLen("Reference Number"));
                    Modify();
                    "Reference Number" := CopyStr(OneChar + "Reference Number", 1, MaxStrLen("Reference Number"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR MM Membership Entry"; "NPR MM Membership Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 5);
                    Dialog.Update(3, "NPR MM Membership Entry".Count());
                    Dialog.Update(4, "NPR MM Membership Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR POS Entry"; "NPR POS Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 6);
                    Dialog.Update(3, "NPR POS Entry".Count());
                    Dialog.Update(4, "NPR POS Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
                CurrReport.Break();
            end;
        }
        dataitem("NPR POS Entry Sales Line"; "NPR POS Entry Sales Line")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 7);
                    Dialog.Update(3, "NPR POS Entry Sales Line".Count());
                    Dialog.Update(4, "NPR POS Entry Sales Line".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR POS Entry Tax Line"; "NPR POS Entry Tax Line")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 8);
                    Dialog.Update(3, "NPR POS Entry Tax Line".Count());
                    Dialog.Update(4, "NPR POS Entry Tax Line".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Print Description" = '' then begin
                    "Print Description" += ' ';
                    Modify();
                    "Print Description" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Print Description", 1, 1);
                    "Print Description" := CopyStr("Print Description", 2, MaxStrLen("Print Description"));
                    Modify();
                    "Print Description" := CopyStr(OneChar + "Print Description", 1, MaxStrLen("Print Description"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR TM Admis. Schedule Entry"; "NPR TM Admis. Schedule Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 9);
                    Dialog.Update(3, "NPR TM Admis. Schedule Entry".Count());
                    Dialog.Update(4, "NPR TM Admis. Schedule Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Reason Code" = '' then begin
                    "Reason Code" += ' ';
                    Modify();
                    "Reason Code" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Reason Code", 1, 1);
                    "Reason Code" := CopyStr("Reason Code", 2, MaxStrLen("Reason Code"));
                    Modify();
                    "Reason Code" := CopyStr(OneChar + "Reason Code", 1, MaxStrLen("Reason Code"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR TM Admis. Schedule Lines"; "NPR TM Admis. Schedule Lines")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 10);
                    Dialog.Update(3, "NPR TM Admis. Schedule Lines".Count());
                    Dialog.Update(4, "NPR TM Admis. Schedule Lines".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Concurrency Code" = '' then begin
                    "Concurrency Code" += ' ';
                    Modify();
                    "Concurrency Code" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Concurrency Code", 1, 1);
                    "Concurrency Code" := CopyStr("Concurrency Code", 2, MaxStrLen("Concurrency Code"));
                    Modify();
                    "Concurrency Code" := CopyStr(OneChar + "Concurrency Code", 1, MaxStrLen("Concurrency Code"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR TM Ticket Access Entry"; "NPR TM Ticket Access Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 11);
                    Dialog.Update(3, "NPR TM Ticket Access Entry".Count());
                    Dialog.Update(4, "NPR TM Ticket Access Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Member Card Code" = '' then begin
                    "Member Card Code" += ' ';
                    Modify();
                    "Member Card Code" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Member Card Code", 1, 1);
                    "Member Card Code" := CopyStr("Member Card Code", 2, MaxStrLen("Member Card Code"));
                    Modify();
                    "Member Card Code" := CopyStr(OneChar + "Member Card Code", 1, MaxStrLen("Member Card Code"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("Value Entry"; "Value Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 12);
                    Dialog.Update(3, "Value Entry".Count());
                    Dialog.Update(4, "Value Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 13);
                    Dialog.Update(3, "Vendor Ledger Entry".Count());
                    Dialog.Update(4, "Vendor Ledger Entry".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if Description = '' then begin
                    Description += ' ';
                    Modify();
                    Description := '';
                    Modify();
                end else begin
                    OneChar := CopyStr(Description, 1, 1);
                    Description := CopyStr(Description, 2, MaxStrLen(Description));
                    Modify();
                    Description := CopyStr(OneChar + Description, 1, MaxStrLen(Description));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
        dataitem("NPR TM Ticket Access Stats"; "NPR TM Ticket Access Stats")
        {
            trigger OnPreDataItem()
            begin
                SetFilter(SystemModifiedAt, '<%1', CreateDateTime(19800101D, 0T));
                i := 0;
                if GuiAllowed then begin
                    Dialog.Update(1, 14);
                    Dialog.Update(3, "NPR TM Ticket Access Stats".Count());
                    Dialog.Update(4, "NPR TM Ticket Access Stats".TableCaption());
                end;
            end;

            trigger OnAfterGetRecord()
            var
                OneChar: Text;
            begin
                i += 1;
                if GuiAllowed then
                    Dialog.Update(2, i);
                if "Admission Code" = '' then begin
                    "Admission Code" += ' ';
                    Modify();
                    "Admission Code" := '';
                    Modify();
                end else begin
                    OneChar := CopyStr("Admission Code", 1, 1);
                    "Admission Code" := CopyStr("Admission Code", 2, MaxStrLen("Admission Code"));
                    Modify();
                    "Admission Code" := CopyStr(OneChar + "Admission Code", 1, MaxStrLen("Admission Code"));
                    Modify();
                end;
                if i mod 10000 = 0 then
                    Commit();
            end;
        }
    }
    trigger OnPostReport()
    begin
        if GuiAllowed() then begin
            Dialog.Close();
            Message('Update completed.');
        end;
    end;

    var
        i: Integer;
        Dialog: Dialog;
        ProgressLbl: Label 'Updating #1 of 14\\ Entries #2 of #3 \\Current table: #4';
}