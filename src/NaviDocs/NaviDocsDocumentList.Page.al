page 6059769 "NPR NaviDocs Document List"
{
    // NPR5.23/THRO/20160601 CASE 236043 SetStatusHandled corrected to set status = Handled, Disabled E-mail Log as function called doesn't exists
    // NPR5.23/MMV /20160609 CASE 240856 Changed key away from status since it will be changed as part of the handling process, causing some records to be hit twice by the record iterator.
    // NPR5.26/THRO/20160808 CASE 248662 Field 3 Type removed. Removed Email log menuitem
    // NPR5.26/THRO/20160908 CASE 250371 Added "Delay sending until"
    // NPR5.30/THRO/20170209 CASE 243998 Logging in Activity Log - link to subpage changed
    // NPR5.36/THRO/20170913 CASE 289216 Added Template Code
    // NPR5.40/THRO/20180301 CASE 306875 Selected fields made editable
    // NPR5.43/THRO/20180531 CASE 315958 Added Attachment subpage

    Caption = 'NaviDocs Document List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Functions,Update,Change Status for Marked';
    SourceTable = "NPR NaviDocs Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Description"; "Document Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. (Recipient)"; "No. (Recipient)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Name (Recipient)"; "Name (Recipient)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(StatusText; StatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;
                    OptionCaption = 'Unhandled,Error,Handled';
                }
                field("Document Handling Profile"; "Document Handling Profile")
                {
                    ApplicationArea = All;
                }
                field("Document Handling"; "Document Handling")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Report No."; "Report No.")
                {
                    ApplicationArea = All;
                }
                field("E-mail (Recipient)"; "E-mail (Recipient)")
                {
                    ApplicationArea = All;
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Printed Qty."; "Printed Qty.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed Qty."; "Processed Qty.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Delay sending until"; "Delay sending until")
                {
                    ApplicationArea = All;
                }
            }
            part(NaviDocsCommentSubpage; "NPR NaviDocs Comment Subpage")
            {
                Editable = false;
                ShowFilter = false;
                ApplicationArea = All;
            }
            part(NaviDocsAttachments; "NPR NaviDocs Entry Attachments")
            {
                ShowFilter = false;
                SubPageLink = "NaviDocs Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("NaviDocs Entry No.", "Line No.");
                Visible = ShowAttachmentSubpage;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("<Action6150636>")
            {
                Caption = 'Functions';
                Image = Action;
                action(Handle)
                {
                    Caption = 'Handle';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        HandleNaviDocs;
                    end;
                }
                action("Handle marked")
                {
                    Caption = 'Handle marked';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        HandleNaviDocs;
                    end;
                }
                separator(Separator6150634)
                {
                }
                action(ShowUnhandled)
                {
                    Caption = 'Show unhandled';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+U';
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        SetRange(Status, 0, 1);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Status)
            {
                Caption = 'Status';
                action(UpdateStatus)
                {
                    Caption = 'Update Status of Marked';
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        CheckAndUpdateStatus;
                    end;
                }
                separator(Separator6150645)
                {
                }
                action(SetStatusUnHandled)
                {
                    Caption = 'Set Status = Unhandled';
                    Image = ChangeStatus;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        ChangeStatus(0);
                    end;
                }
                action(SetStatusError)
                {
                    Caption = 'Set Status = Error';
                    Image = ChangeStatus;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        ChangeStatus(1);
                    end;
                }
                action(SetStatusHandled)
                {
                    Caption = 'Set Status = Handled';
                    Image = ChangeStatus;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        //-NPR5.23 [236043]
                        //ChangeStatus(1);
                        ChangeStatus(2);
                        //+NPR5.23 [236043]
                    end;
                }
            }
            group("Handling Profile")
            {
                Caption = 'Handling Profile';
                action(DoChangeHandlingProfile)
                {
                    Caption = 'Change Handling Profile';
                    Image = SendToMultiple;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [306875]
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        ChangeHandlingProfile;
                        //+NPR5.40 [306875]
                    end;
                }
            }
        }
        area(navigation)
        {
            action(DocumentCard)
            {
                Caption = 'Document Card';
                Image = GetSourceDoc;
                Promoted = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Shift+F5';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NaviDocsManagement.PageDocumentCard(Rec);
                end;
            }
            action("Master Card")
            {
                Caption = 'Master Card';
                Image = GetSourceDoc;
                Promoted = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+F5';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NaviDocsManagement.PageAccountCard(Rec);
                end;
            }
            action("E-mail Template")
            {
                Caption = 'Template';
                Image = MailAttachment;
                Promoted = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+M';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NaviDocsManagement.PageMailAndDocCard(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.30 [243998]
        CurrPage.NaviDocsCommentSubpage.PAGE.SetData(Rec, NaviDocsSetup."Log to Activity Log");
        //+NPR5.30 [243998]
    end;

    trigger OnAfterGetRecord()
    begin
        StatusText := Status;
    end;

    trigger OnOpenPage()
    var
        NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment";
    begin
        //-NPR5.30 [243998]
        NaviDocsSetup.Get;
        //+NPR5.30 [243998]
        //-NPR5.43 [315958]
        ShowAttachmentSubpage := not NaviDocsEntryAttachment.IsEmpty;
        //+NPR5.43 [315958]
    end;

    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        NaviDocsEntry2: Record "NPR NaviDocs Entry";
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        StatusText: Option UnHandled,Error,Handled;
        TxtConfirm001: Label '%1 Documents will be %2\Continue?';
        TxtConfirm011: Label 'Handled';
        TxtConfirm012: Label 'Status Updated';
        TxtConfirm020: Label 'Aborted';
        TxtHandled001: Label '%1 Documents has not yet been handled.';
        TxtHandled002: Label 'All Documents has been handled.';
        TxtConfirmHandleChanged: Label 'Handle the changed Documents?';
        ShowAttachmentSubpage: Boolean;

    local procedure HandleNaviDocs()
    var
        NaviDocsEntry3: Record "NPR NaviDocs Entry";
    begin
        //-NPR5.23 [240856]
        //NaviDocsEntry2.SETCURRENTKEY(Type, Status);
        NaviDocsEntry2.SetCurrentKey("Entry No.");
        //+NPR5.23 [240856]
        //-NPR5.26 [248662]
        //NaviDocsEntry2.SETRANGE(Type,Type::"2");
        //+NPR5.26 [248662]
        NaviDocsEntry2.SetRange(Status, 0, 1);

        if not Confirm(StrSubstNo(TxtConfirm001, Format(NaviDocsEntry2.Count), TxtConfirm011), true) then
            Error(TxtConfirm020);

        if NaviDocsEntry2.FindSet then
            repeat
                NaviDocsEntry3.Copy(NaviDocsEntry2);
                if NaviDocsManagement.Run(NaviDocsEntry3) then;
                //NaviDocsManagement.RUN(NaviDocsEntry3);
                Commit;
            until NaviDocsEntry2.Next = 0;

        NaviDocsEntry2.Reset;
        //-NPR5.26 [248662]
        //NaviDocsEntry2.SETCURRENTKEY(Type, Status);
        //NaviDocsEntry2.SETRANGE(Type,Type::"2");
        NaviDocsEntry2.SetCurrentKey(Status);
        //+NPR5.26 [248662]
        NaviDocsEntry2.SetRange(Status, 0, 1);
        if NaviDocsEntry2.Count > 0 then
            Message(TxtHandled001, NaviDocsEntry2.Count)
        else
            Message(TxtHandled002);

        CurrPage.Update(false);
    end;

    procedure CheckAndUpdateStatus()
    begin
        Clear(NaviDocsEntry2);
        NaviDocsEntry2.SetCurrentKey(Status);
        CurrPage.SetSelectionFilter(NaviDocsEntry2);
        NaviDocsEntry2.SetRange(Status, 0, 1);
        if NaviDocsEntry2.FindSet then
            repeat
                if NaviDocsManagement.CheckAndUpdateStatus(NaviDocsEntry2) then
                    Commit;
            until NaviDocsEntry2.Next = 0;

        CurrPage.Update(false);
    end;

    local procedure ChangeStatus(UpdateStatus: Integer)
    var
        NaviDocsEntry3: Record "NPR NaviDocs Entry";
    begin
        if not Confirm(StrSubstNo(TxtConfirm001, Format(NaviDocsEntry2.Count), TxtConfirm012)) then
            Error(TxtConfirm020);

        if NaviDocsEntry2.FindSet then
            repeat
                NaviDocsEntry3.Copy(NaviDocsEntry2);
                NaviDocsManagement.UpdateStatus(NaviDocsEntry3, UpdateStatus);
                Commit;
            until NaviDocsEntry2.Next = 0;

        CurrPage.Update(false);
    end;

    local procedure ChangeHandlingProfile()
    var
        NewHandlingProfile: Record "NPR NaviDocs Handling Profile";
        TempChangedNaviDocsEntry: Record "NPR NaviDocs Entry" temporary;
    begin
        //-NPR5.40 [306875]
        NaviDocsEntry2.SetCurrentKey("Entry No.");

        if PAGE.RunModal(0, NewHandlingProfile) <> ACTION::LookupOK then
            exit;
        if NaviDocsEntry2.FindSet then
            repeat
                if NaviDocsManagement.SetHandlingProfile(NaviDocsEntry2, NewHandlingProfile) then begin
                    TempChangedNaviDocsEntry := NaviDocsEntry2;
                    TempChangedNaviDocsEntry.Insert;
                    Commit;
                end;
            until NaviDocsEntry2.Next = 0;

        if TempChangedNaviDocsEntry.FindSet then
            if Confirm(TxtConfirmHandleChanged) then
                repeat
                    NaviDocsEntry2.Get(TempChangedNaviDocsEntry."Entry No.");
                    NaviDocsEntry2.Status := 0;
                    if NaviDocsManagement.Run(NaviDocsEntry2) then;
                    Commit;
                until TempChangedNaviDocsEntry.Next = 0;

        NaviDocsEntry2.Reset;
        CurrPage.Update(false);
        //+NPR5.40 [306875]
    end;
}

