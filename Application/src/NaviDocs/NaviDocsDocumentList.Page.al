page 6059769 "NPR NaviDocs Document List"
{
    Caption = 'NaviDocs Document List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Functions,Update,Change Status for Marked';
    SourceTable = "NPR NaviDocs Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Description"; Rec."Document Description")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Order No."; Rec."Order No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Order No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. (Recipient)"; Rec."No. (Recipient)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. (Recipient) field';
                    ApplicationArea = NPRRetail;
                }
                field("Name (Recipient)"; Rec."Name (Recipient)")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Name (Recipient) field';
                    ApplicationArea = NPRRetail;
                }
                field(StatusText; StatusText)
                {

                    Caption = 'Status';
                    Editable = false;
                    OptionCaption = 'Unhandled,Error,Handled';
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Handling Profile"; Rec."Document Handling Profile")
                {

                    ToolTip = 'Specifies the value of the Document Handling Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Handling"; Rec."Document Handling")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Handling field';
                    ApplicationArea = NPRRetail;
                }
                field("Report No."; Rec."Report No.")
                {

                    ToolTip = 'Specifies the value of the Report No. field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail (Recipient)"; Rec."E-mail (Recipient)")
                {

                    ToolTip = 'Specifies the value of the E-mail (Recipient) field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Code"; Rec."Template Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Printed Qty."; Rec."Printed Qty.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Printed Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Processed Qty."; Rec."Processed Qty.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Processed Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Delay sending until"; Rec."Delay sending until")
                {

                    ToolTip = 'Specifies the value of the Delay sending until field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(NaviDocsCommentSubpage; "NPR NaviDocs Comment Subpage")
            {
                Editable = false;
                ShowFilter = false;
                ApplicationArea = NPRRetail;

            }
            part(NaviDocsAttachments; "NPR NaviDocs Entry Attachments")
            {
                ShowFilter = false;
                SubPageLink = "NaviDocs Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("NaviDocs Entry No.", "Line No.");
                Visible = ShowAttachmentSubpage;
                ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    ToolTip = 'Executes the Handle action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        HandleNaviDocs();
                    end;
                }
                action("Handle marked")
                {
                    Caption = 'Handle marked';
                    Image = Start;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    ToolTip = 'Executes the Handle marked action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        HandleNaviDocs();
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+U';

                    ToolTip = 'Executes the Show unhandled action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.SetRange(Status, 0, 1);
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
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Update Status of Marked action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        CheckAndUpdateStatus();
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
                    PromotedOnly = true;
                    PromotedCategory = Category6;

                    ToolTip = 'Executes the Set Status = Unhandled action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Category6;

                    ToolTip = 'Executes the Set Status = Error action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Category6;

                    ToolTip = 'Executes the Set Status = Handled action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        ChangeStatus(2);
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

                    ToolTip = 'Executes the Change Handling Profile action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Clear(NaviDocsEntry2);
                        CurrPage.SetSelectionFilter(NaviDocsEntry2);
                        ChangeHandlingProfile();
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
                PromotedOnly = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Shift+F5';

                ToolTip = 'Executes the Document Card action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+F5';

                ToolTip = 'Executes the Master Card action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+M';

                ToolTip = 'Executes the Template action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    NaviDocsManagement.PageMailAndDocCard(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.NaviDocsCommentSubpage.PAGE.SetData(Rec, NaviDocsSetup."Log to Activity Log");
    end;

    trigger OnAfterGetRecord()
    begin
        StatusText := Rec.Status;
    end;

    trigger OnOpenPage()
    var
        NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment";
    begin
        NaviDocsSetup.Get();
        ShowAttachmentSubpage := not NaviDocsEntryAttachment.IsEmpty();
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
        NaviDocsEntry2.SetCurrentKey("Entry No.");
        NaviDocsEntry2.SetRange(Status, 0, 1);

        if not Confirm(StrSubstNo(TxtConfirm001, Format(NaviDocsEntry2.Count), TxtConfirm011), true) then
            Error(TxtConfirm020);

        if NaviDocsEntry2.FindSet() then
            repeat
                NaviDocsEntry3.Copy(NaviDocsEntry2);
                NaviDocsManagement.Process(NaviDocsEntry3);
                Commit();
            until NaviDocsEntry2.Next() = 0;

        NaviDocsEntry2.Reset();
        NaviDocsEntry2.SetCurrentKey(Status);
        NaviDocsEntry2.SetRange(Status, 0, 1);
        if NaviDocsEntry2.Count() > 0 then
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
        if NaviDocsEntry2.FindSet() then
            repeat
                if NaviDocsManagement.CheckAndUpdateStatus(NaviDocsEntry2) then
                    Commit();
            until NaviDocsEntry2.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure ChangeStatus(UpdateStatus: Integer)
    var
        NaviDocsEntry3: Record "NPR NaviDocs Entry";
    begin
        if not Confirm(StrSubstNo(TxtConfirm001, Format(NaviDocsEntry2.Count), TxtConfirm012)) then
            Error(TxtConfirm020);

        if NaviDocsEntry2.FindSet() then
            repeat
                NaviDocsEntry3.Copy(NaviDocsEntry2);
                NaviDocsManagement.UpdateStatus(NaviDocsEntry3, UpdateStatus);
                Commit();
            until NaviDocsEntry2.Next() = 0;

        CurrPage.Update(false);
    end;

    local procedure ChangeHandlingProfile()
    var
        NewHandlingProfile: Record "NPR NaviDocs Handling Profile";
        TempChangedNaviDocsEntry: Record "NPR NaviDocs Entry" temporary;
    begin
        NaviDocsEntry2.SetCurrentKey("Entry No.");

        if PAGE.RunModal(0, NewHandlingProfile) <> ACTION::LookupOK then
            exit;
        if NaviDocsEntry2.FindSet() then
            repeat
                if NaviDocsManagement.SetHandlingProfile(NaviDocsEntry2, NewHandlingProfile) then begin
                    TempChangedNaviDocsEntry := NaviDocsEntry2;
                    TempChangedNaviDocsEntry.Insert();
                    Commit();
                end;
            until NaviDocsEntry2.Next() = 0;

        if TempChangedNaviDocsEntry.FindSet() then
            if Confirm(TxtConfirmHandleChanged) then
                repeat
                    NaviDocsEntry2.Get(TempChangedNaviDocsEntry."Entry No.");
                    NaviDocsEntry2.Status := 0;
                    if NaviDocsManagement.Run(NaviDocsEntry2) then;
                    Commit();
                until TempChangedNaviDocsEntry.Next() = 0;

        NaviDocsEntry2.Reset();
        CurrPage.Update(false);
    end;
}

