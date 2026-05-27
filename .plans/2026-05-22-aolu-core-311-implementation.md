# CORE-311 Subpages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three new ListPart subpages (Ticket, Coupon, Wallet) on the parent `NPR Ecom Sales Document` page, populated by the existing Page Background Task orchestrator. Mirror the established Voucher/Membership pattern exactly.

**Architecture:** Each new asset gets a dedicated subpage page (temporary source, JSON-populated), a `BuildXTempBufferForDoc` / `BuildXTempBufferForLine` extracted from the existing `ShowRelatedXAction`, an `OpenXCardForSystemId` for the per-row Open action, and a `BuildXPayload` in the orchestrator under a new result-key token. The parent page mounts the three new parts, routes results in `OnPageBackgroundTaskCompleted`, clears them in `EnqueueSubpagesRefresh`, and extends `AllSubpagesLoaded` to require all 5 keys. The orchestrator stays single-task with one `HeaderSystemId` parameter.

**Tech Stack:** AL (Microsoft Dynamics 365 Business Central 17→latest), Page Background Tasks, JSON serialization, temporary records.

**Spec:** `.plans/2026-05-22-aolu-core-311-design.md`

---

## File Structure

**New files:**
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomTicketSub.Page.al` — new ListPart subpage for tickets
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCouponSub.Page.al` — new ListPart subpage for coupons
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomWalletSub.Page.al` — new ListPart subpage for wallets

**Modified files:**
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomCreateTicketImpl.Codeunit.al` — extract iterator, add OpenTicketCardForSystemId, refactor line-level ShowRelated to count-switch
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponImpl.Codeunit.al` — same pattern
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al` — extract iterator, add OpenWalletCardForSystemId, replace `ShowRelatedWallets(TableId, SystemId)` with two `ShowRelatedWalletsAction(Rec)` typed overloads
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al` — add 3 `BuildXPayload` + 3 `XResultKeyTok` + 3 calls in `OnRun`
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al` — add 3 `part(...)`, 3 routing branches in `OnPageBackgroundTaskCompleted`, 3 `ClearContents` in `EnqueueSubpagesRefresh`/`ClearAllSubpages`, migrate wallet call site at L478
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocSub.Page.al` — migrate wallet call site at L180
- `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLines.Page.al` — migrate wallet call site at L168

**App.json IDs to allocate:** 3 page IDs (Ticket Sub, Coupon Sub, Wallet Sub).

---

## Task 1: Allocate 3 page IDs via AL ID Manager

**Files:** None modified yet — IDs will be used in Tasks 3, 5, 8.

- [ ] **Step 1: Get next available page IDs from al-id-manager**

App ID from `Application/app.json`: `992c2309-cca4-43cb-9e41-911f482ec088`.
Page ranges declared in app.json: `6014400-6014699, 6059767-6060166, 6150613-6151612, 6184471-6185130, 6248181-6249170`.

The API key is stored in your local memory (`MEMORY.md` → AL ID Manager section) — set it as an env var before running the commands:

```powershell
$env:AL_ID_MANAGER_KEY = "<api-key-from-memory>"
```

Run the following 3 curl commands (one per page) and capture the returned `id` for each. The API marks them reserved server-side — record them now in the plan to avoid drift.

```bash
curl -s -X POST 'https://al-id-manager.npretail.io/api/reserve' \
  -H 'Content-Type: application/json' \
  -H "X-API-Key: $env:AL_ID_MANAGER_KEY" \
  -d '{
    "appId": "992c2309-cca4-43cb-9e41-911f482ec088",
    "objectType": "page",
    "name": "NPR Ecom Ticket Sub"
  }'
```

Expected response: `{"id": <N>, "available": true}`

Repeat for `"NPR Ecom Coupon Sub"` and `"NPR Ecom Wallet Sub"`.

- [ ] **Step 2: Record IDs in plan**

Edit this file and replace the placeholders below with the actual reserved IDs.

```
TICKET_SUB_PAGE_ID = 6150947
COUPON_SUB_PAGE_ID = 6150948
WALLET_SUB_PAGE_ID = 6150949
```

(Initial al-id-manager calls returned 6150945, 6150946, 6150947 — 6150945 collided with `NPR CMOrderWallets` and 6150946 collided with `NPR NPRE Seating Location Card` because the al-id-manager isn't fully seeded with all existing pages. After verifying each returned ID against `Grep ^page <N> ` in `Application/src`, the truly-free triple is 6150947 / 6150948 / 6150949. Reservations 6150945 and 6150946 are abandoned in the al-id-manager registry.)

- [ ] **Step 3: Verify reservations**

For each reserved ID, run a GET to confirm it is allocated to this app:

```bash
curl -s 'https://al-id-manager.npretail.io/api/check?appId=992c2309-cca4-43cb-9e41-911f482ec088&objectType=page&id=<TICKET_SUB_PAGE_ID>' \
  -H "X-API-Key: $env:AL_ID_MANAGER_KEY"
```

Expected response: `{"available": false, "reservedFor": "NPR Ecom Ticket Sub"}` (the ID is reserved, not available).

- [ ] **Step 4: No commit yet**

IDs are recorded in this plan file only. Commit happens when the first page is created (Task 3).

---

## Task 2: Refactor `EcomCreateTicketImpl` — extract iterator + add OpenCard + count-switch

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomCreateTicketImpl.Codeunit.al`

The existing `ShowRelatedTicketsAction(EcomSalesHeader)` (lines 314-325) and `(EcomSalesLine)` (lines 327-337) currently inline the iterator logic and the `Page.RunModal` call. Extract iterator into `BuildTicketTempBufferForDoc` / `BuildTicketTempBufferForLine`, add `OpenTicketCardForSystemId`, and rewrite `ShowRelatedTicketsAction(EcomSalesLine)` to use count-switch.

- [ ] **Step 1: Read existing `ShowRelatedTicketsAction` overloads**

Open the file, locate `ShowRelatedTicketsAction(EcomSalesHeader)` and `(EcomSalesLine)`. Identify the iterator block (filter on `NPR TM Ticket Reservation Req.` by `Session Token ID` or `GetBySystemId(... Line Id)`, joined-loop into temp `NPR TM Ticket` by `Ticket Reservation Entry No.`).

- [ ] **Step 2: Add `BuildTicketTempBufferForDoc` procedure**

Append after the last existing procedure (before any `local procedure` already at the bottom). The body extracts the header-level iterator. Defensive: skip records where `NPR TM Ticket.Get(...)` fails — never `Error`.

```al
internal procedure BuildTicketTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempTicket: Record "NPR TM Ticket" temporary)
var
    TicketReservReq: Record "NPR TM Ticket Reservation Req.";
    Ticket: Record "NPR TM Ticket";
begin
    if EcomSalesHeader."Ticket Reservation Token" = '' then
        exit;
    TicketReservReq.SetCurrentKey("Session Token ID");
    TicketReservReq.SetRange("Session Token ID", EcomSalesHeader."Ticket Reservation Token");
    if not TicketReservReq.FindSet() then
        exit;
    repeat
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservReq."Entry No.");
        if Ticket.FindSet() then
            repeat
                TempTicket := Ticket;
                TempTicket.SystemId := Ticket.SystemId;
                if TempTicket.Insert(false, true) then;
            until Ticket.Next() = 0;
    until TicketReservReq.Next() = 0;
end;
```

- [ ] **Step 3: Add `BuildTicketTempBufferForLine` procedure**

```al
internal procedure BuildTicketTempBufferForLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var TempTicket: Record "NPR TM Ticket" temporary)
var
    TicketReservReq: Record "NPR TM Ticket Reservation Req.";
    Ticket: Record "NPR TM Ticket";
begin
    if IsNullGuid(EcomSalesLine."Ticket Reservation Line Id") then
        exit;
    if not TicketReservReq.GetBySystemId(EcomSalesLine."Ticket Reservation Line Id") then
        exit;
    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
    Ticket.SetRange("Ticket Reservation Entry No.", TicketReservReq."Entry No.");
    if Ticket.FindSet() then
        repeat
            TempTicket := Ticket;
            TempTicket.SystemId := Ticket.SystemId;
            if TempTicket.Insert(false, true) then;
        until Ticket.Next() = 0;
end;
```

Note: `EcomSalesHeader` parameter removed — the line-level iterator only needs `EcomSalesLine`. This deviates slightly from the `BuildXTempBufferForLine(Header, Line, ...)` signature used by Voucher/Membership, but the analyzer would flag the unused header parameter (AA0137).

- [ ] **Step 4: Add `OpenTicketCardForSystemId` procedure**

```al
internal procedure OpenTicketCardForSystemId(SystemIdParam: Guid)
var
    Ticket: Record "NPR TM Ticket";
    NotAvailableMsg: Label 'This ticket is no longer available in the system.';
begin
    if not Ticket.GetBySystemId(SystemIdParam) then begin
        Message(NotAvailableMsg);
        exit;
    end;
    Ticket.SetRecFilter();
    Page.Run(Page::"NPR TM Ticket Card", Ticket);
end;
```

- [ ] **Step 5: Rewrite `ShowRelatedTicketsAction(EcomSalesHeader)` body**

Replace the existing body (the entire `begin..end;` block of the header overload) with:

```al
internal procedure ShowRelatedTicketsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    TempTicket: Record "NPR TM Ticket" temporary;
begin
    BuildTicketTempBufferForDoc(EcomSalesHeader, TempTicket);
    if not TempTicket.IsEmpty() then
        Page.RunModal(Page::"NPR TM Ticket List", TempTicket);
end;
```

- [ ] **Step 6: Rewrite `ShowRelatedTicketsAction(EcomSalesLine)` body**

Replace with count-switch using the new helpers:

```al
internal procedure ShowRelatedTicketsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
var
    TempTicket: Record "NPR TM Ticket" temporary;
    NoTicketFoundMsg: Label 'No tickets are linked to this line.';
begin
    BuildTicketTempBufferForLine(EcomSalesLine, TempTicket);
    case TempTicket.Count() of
        0:
            Message(NoTicketFoundMsg);
        1:
            begin
                TempTicket.FindFirst();
                OpenTicketCardForSystemId(TempTicket.SystemId);
            end;
        else
            Page.RunModal(Page::"NPR TM Ticket List", TempTicket);
    end;
end;
```

- [ ] **Step 7: Verify compile**

Run:

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: compile succeeds with no new warnings/errors.

- [ ] **Step 8: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomCreateTicketImpl.Codeunit.al
git commit -m "Extract Ticket iterators + add OpenTicketCardForSystemId + count-switch (CORE-311)"
```

---

## Task 3: Create `NPR Ecom Ticket Sub` page

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomTicketSub.Page.al`

- [ ] **Step 1: Create the file with full page definition**

Use `TICKET_SUB_PAGE_ID` reserved in Task 1.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page <TICKET_SUB_PAGE_ID> "NPR Ecom Ticket Sub"
{
    Caption = 'Tickets';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR TM Ticket";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the internal ticket number.';
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the external ticket number presented to the customer.';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ticket type.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number this ticket was sold under.';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date from which the ticket is valid.';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time from which the ticket is valid.';
                }
                field("Valid To Date"; Rec."Valid To Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date until which the ticket is valid.';
                }
                field("Valid To Time"; Rec."Valid To Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time until which the ticket is valid.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenTicket)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected ticket to see full details.';

                trigger OnAction()
                var
                    EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
                begin
                    EcomCreateTicketImpl.OpenTicketCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    /// <summary>
    /// Clears the temp buffer. Called by the parent page before enqueueing a background task
    /// or on task error.
    /// </summary>
    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Populates the temp buffer from a JSON array payload produced by the parent's background
    /// task. Insert(false, true): preserve SystemId for the Open action.
    /// </summary>
    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        TicketsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and TicketsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(TicketsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(TicketsJson: JsonArray)
    var
        TicketToken: JsonToken;
        TicketObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
        DateText: Text;
        TimeText: Text;
        ParsedDate: Date;
        ParsedTime: Time;
    begin
        foreach TicketToken in TicketsJson do begin
            TicketObj := TicketToken.AsObject();
            Rec.Init();
            if TicketObj.Get('No', FieldToken) then
                Rec."No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."No."));
            if TicketObj.Get('Ext', FieldToken) then
                Rec."External Ticket No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."External Ticket No."));
            if TicketObj.Get('Type', FieldToken) then
                Rec."Ticket Type Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Ticket Type Code"));
            if TicketObj.Get('Item', FieldToken) then
                Rec."Item No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Item No."));
            if TicketObj.Get('VFromD', FieldToken) then begin
                DateText := FieldToken.AsValue().AsText();
                if (DateText <> '') and Evaluate(ParsedDate, DateText, 9) then
                    Rec."Valid From Date" := ParsedDate;
            end;
            if TicketObj.Get('VFromT', FieldToken) then begin
                TimeText := FieldToken.AsValue().AsText();
                if (TimeText <> '') and Evaluate(ParsedTime, TimeText, 9) then
                    Rec."Valid From Time" := ParsedTime;
            end;
            if TicketObj.Get('VToD', FieldToken) then begin
                DateText := FieldToken.AsValue().AsText();
                if (DateText <> '') and Evaluate(ParsedDate, DateText, 9) then
                    Rec."Valid To Date" := ParsedDate;
            end;
            if TicketObj.Get('VToT', FieldToken) then begin
                TimeText := FieldToken.AsValue().AsText();
                if (TimeText <> '') and Evaluate(ParsedTime, TimeText, 9) then
                    Rec."Valid To Time" := ParsedTime;
            end;
            if TicketObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
```

- [ ] **Step 2: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: compile succeeds (the page will not yet be referenced from the parent — that comes in Task 10).

- [ ] **Step 3: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Ticket/EcomTicketSub.Page.al
git commit -m "Add NPR Ecom Ticket Sub subpage (CORE-311)"
```

---

## Task 4: Refactor `EcomCreateCouponImpl` — extract iterator + add OpenCard + count-switch

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponImpl.Codeunit.al`

The existing `ShowRelatedCouponsAction(EcomSalesHeader)` (lines 87-94) and `(EcomSalesLine)` (lines 96-103) inline the iterator. Coupon already has its own link table `NPR Ecom Sales Coupon Link` (table 6059934).

- [ ] **Step 1: Add `BuildCouponTempBufferForDoc`**

```al
internal procedure BuildCouponTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempCoupon: Record "NPR NpDc Coupon" temporary)
var
    EmptyGuid: Guid;
begin
    BuildCouponTempBuffer(EcomSalesHeader, EmptyGuid, TempCoupon);
end;
```

- [ ] **Step 2: Add `BuildCouponTempBufferForLine`**

```al
internal procedure BuildCouponTempBufferForLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempCoupon: Record "NPR NpDc Coupon" temporary)
begin
    BuildCouponTempBuffer(EcomSalesHeader, EcomSalesLine.SystemId, TempCoupon);
end;
```

- [ ] **Step 3: Add `BuildCouponTempBuffer` (internal iterator)**

```al
local procedure BuildCouponTempBuffer(EcomSalesHeader: Record "NPR Ecom Sales Header"; SourceLineSystemIdFilter: Guid; var TempCoupon: Record "NPR NpDc Coupon" temporary)
var
    EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
    NpDcCoupon: Record "NPR NpDc Coupon";
begin
    EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink.Source::"Ecom Sales Document");
    EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
    if not IsNullGuid(SourceLineSystemIdFilter) then
        EcomSalesCouponLink.SetRange("Source Line System Id", SourceLineSystemIdFilter);
    if EcomSalesCouponLink.FindSet() then
        repeat
            if NpDcCoupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id") then begin
                TempCoupon := NpDcCoupon;
                TempCoupon.SystemId := NpDcCoupon.SystemId;
                if TempCoupon.Insert(false, true) then;
            end;
        until EcomSalesCouponLink.Next() = 0;
end;
```

Field names and enum value confirmed in source: `NPR Ecom Sales Coupon Link` has `Source`, `Source System Id`, `Source Line System Id`, `Coupon System Id`. `NPR Ecom Sales Coupon Source` enum has value `"Ecom Sales Document"`. No verification needed.

- [ ] **Step 4: Add `OpenCouponCardForSystemId`**

```al
internal procedure OpenCouponCardForSystemId(SystemIdParam: Guid)
var
    NpDcCoupon: Record "NPR NpDc Coupon";
    NotAvailableMsg: Label 'This coupon is no longer available in the system.';
begin
    if not NpDcCoupon.GetBySystemId(SystemIdParam) then begin
        Message(NotAvailableMsg);
        exit;
    end;
    NpDcCoupon.SetRecFilter();
    Page.Run(Page::"NPR NpDc Coupon Card", NpDcCoupon);
end;
```

- [ ] **Step 5: Rewrite `ShowRelatedCouponsAction(EcomSalesHeader)`**

```al
internal procedure ShowRelatedCouponsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    TempCoupon: Record "NPR NpDc Coupon" temporary;
begin
    BuildCouponTempBufferForDoc(EcomSalesHeader, TempCoupon);
    if not TempCoupon.IsEmpty() then
        Page.RunModal(0, TempCoupon);
end;
```

- [ ] **Step 6: Rewrite `ShowRelatedCouponsAction(EcomSalesLine)`**

```al
internal procedure ShowRelatedCouponsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
var
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    TempCoupon: Record "NPR NpDc Coupon" temporary;
    NoCouponFoundMsg: Label 'No coupons are linked to this line.';
begin
    if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then
        exit;
    BuildCouponTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempCoupon);
    case TempCoupon.Count() of
        0:
            Message(NoCouponFoundMsg);
        1:
            begin
                TempCoupon.FindFirst();
                OpenCouponCardForSystemId(TempCoupon.SystemId);
            end;
        else
            Page.RunModal(0, TempCoupon);
    end;
end;
```

- [ ] **Step 7: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: success.

- [ ] **Step 8: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCreateCouponImpl.Codeunit.al
git commit -m "Extract Coupon iterators + add OpenCouponCardForSystemId + count-switch (CORE-311)"
```

---

## Task 5: Create `NPR Ecom Coupon Sub` page

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCouponSub.Page.al`

- [ ] **Step 1: Create the file**

Use `COUPON_SUB_PAGE_ID` from Task 1.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page <COUPON_SUB_PAGE_ID> "NPR Ecom Coupon Sub"
{
    Caption = 'Coupons';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR NpDc Coupon";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the coupon number.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer-facing reference number.';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the coupon type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the coupon description.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the coupon became valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the coupon expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenCoupon)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected coupon to see full details and entries.';

                trigger OnAction()
                var
                    EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
                begin
                    EcomCreateCouponImpl.OpenCouponCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        CouponsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and CouponsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(CouponsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(CouponsJson: JsonArray)
    var
        CouponToken: JsonToken;
        CouponObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
        DateText: Text;
        ParsedDateTime: DateTime;
    begin
        foreach CouponToken in CouponsJson do begin
            CouponObj := CouponToken.AsObject();
            Rec.Init();
            if CouponObj.Get('No', FieldToken) then
                Rec."No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."No."));
            if CouponObj.Get('Ref', FieldToken) then
                Rec."Reference No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Reference No."));
            if CouponObj.Get('Type', FieldToken) then
                Rec."Coupon Type" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Coupon Type"));
            if CouponObj.Get('Desc', FieldToken) then
                Rec.Description := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if CouponObj.Get('Start', FieldToken) then begin
                DateText := FieldToken.AsValue().AsText();
                if (DateText <> '') and Evaluate(ParsedDateTime, DateText, 9) then
                    Rec."Starting Date" := ParsedDateTime;
            end;
            if CouponObj.Get('End', FieldToken) then begin
                DateText := FieldToken.AsValue().AsText();
                if (DateText <> '') and Evaluate(ParsedDateTime, DateText, 9) then
                    Rec."Ending Date" := ParsedDateTime;
            end;
            if CouponObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
```

Coupon `Starting Date` / `Ending Date` are `DateTime` fields (confirmed from source). The `Format(..., 0, 9)` serialize + `Evaluate(ParsedDateTime, ..., 9)` deserialize round-trip works correctly for DateTime values.

- [ ] **Step 2: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

- [ ] **Step 3: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Coupon/EcomCouponSub.Page.al
git commit -m "Add NPR Ecom Coupon Sub subpage (CORE-311)"
```

---

## Task 6: Refactor `EcomCreateWalletMgt` — extract iterator, rename to typed overloads, add OpenCard

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al`

Both the procedure `ShowRelatedWallets(TableId, SystemId)` and the codeunit are `Access = Internal` — safe rename, no breaking change.

- [ ] **Step 1: Read existing `ShowRelatedWallets(TableId, SystemId)` body**

Located at lines 206-235. Identify the iterator (filter `NPR WalletAssetHeaderReference` by `LinkToTableId` + `LinkToSystemId`, walk `WalletAssetHeader` → `WalletAssetLine (Type::WALLET)` → `NPR AttractionWallet`).

- [ ] **Step 2: Add `BuildWalletTempBufferFor` (internal iterator, no UI)**

```al
internal procedure BuildWalletTempBufferFor(LinkToTableIdParam: Integer; LinkToSystemIdParam: Guid; var TempWallet: Record "NPR AttractionWallet" temporary)
var
    WalletAssetHeaderReference: Record "NPR WalletAssetHeaderReference";
    WalletAssetHeader: Record "NPR WalletAssetHeader";
    WalletAssetLine: Record "NPR WalletAssetLine";
    AttractionWallet: Record "NPR AttractionWallet";
begin
    WalletAssetHeaderReference.SetRange(LinkToTableId, LinkToTableIdParam);
    WalletAssetHeaderReference.SetRange(LinkToSystemId, LinkToSystemIdParam);
    if not WalletAssetHeaderReference.FindSet() then
        exit;
    repeat
        if WalletAssetHeader.Get(WalletAssetHeaderReference.WalletHeaderEntryNo) then begin
            WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
            WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);
            if WalletAssetLine.FindSet() then
                repeat
                    if AttractionWallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then begin
                        TempWallet := AttractionWallet;
                        TempWallet.SystemId := AttractionWallet.SystemId;
                        if TempWallet.Insert(false, true) then;
                    end;
                until WalletAssetLine.Next() = 0;
        end;
    until WalletAssetHeaderReference.Next() = 0;
end;
```

Parameter rename `LinkToTableId` → `LinkToTableIdParam` avoids field/parameter ambiguity per AL convention.

- [ ] **Step 3: Add `BuildWalletTempBufferForDoc` wrapper**

```al
internal procedure BuildWalletTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempWallet: Record "NPR AttractionWallet" temporary)
begin
    BuildWalletTempBufferFor(Database::"NPR Ecom Sales Header", EcomSalesHeader.SystemId, TempWallet);
end;
```

- [ ] **Step 4: Add `BuildWalletTempBufferForLine` wrapper**

```al
internal procedure BuildWalletTempBufferForLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var TempWallet: Record "NPR AttractionWallet" temporary)
begin
    BuildWalletTempBufferFor(Database::"NPR Ecom Sales Line", EcomSalesLine.SystemId, TempWallet);
end;
```

- [ ] **Step 5: Add `OpenWalletCardForSystemId`**

```al
internal procedure OpenWalletCardForSystemId(SystemIdParam: Guid)
var
    AttractionWallet: Record "NPR AttractionWallet";
    NotAvailableMsg: Label 'This wallet is no longer available in the system.';
begin
    if not AttractionWallet.GetBySystemId(SystemIdParam) then begin
        Message(NotAvailableMsg);
        exit;
    end;
    AttractionWallet.SetRecFilter();
    Page.Run(Page::"NPR AttractionWalletCard", AttractionWallet);
end;
```

- [ ] **Step 6: Add `ShowRelatedWalletsAction(EcomSalesHeader)`**

```al
internal procedure ShowRelatedWalletsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
var
    TempWallet: Record "NPR AttractionWallet" temporary;
begin
    BuildWalletTempBufferForDoc(EcomSalesHeader, TempWallet);
    if not TempWallet.IsEmpty() then
        Page.RunModal(Page::"NPR AttractionWallets", TempWallet);
end;
```

- [ ] **Step 7: Add `ShowRelatedWalletsAction(EcomSalesLine)`**

```al
internal procedure ShowRelatedWalletsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
var
    TempWallet: Record "NPR AttractionWallet" temporary;
    NoWalletFoundMsg: Label 'No wallets are linked to this line.';
begin
    BuildWalletTempBufferForLine(EcomSalesLine, TempWallet);
    case TempWallet.Count() of
        0:
            Message(NoWalletFoundMsg);
        1:
            begin
                TempWallet.FindFirst();
                OpenWalletCardForSystemId(TempWallet.SystemId);
            end;
        else
            Page.RunModal(Page::"NPR AttractionWallets", TempWallet);
    end;
end;
```

- [ ] **Step 8: Remove old `ShowRelatedWallets(TableId, SystemId)` procedure**

Delete the entire `ShowRelatedWallets(TableId: Integer; SystemId: Guid)` procedure (lines 206-235).

- [ ] **Step 9: Do NOT compile yet**

The 3 call sites for `ShowRelatedWallets(TableId, SystemId)` still exist in other files. They'll be migrated in Task 7. Skip compile and commit until Task 7 completes — they go together.

---

## Task 7: Migrate 3 wallet call sites

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al` (line 478)
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocSub.Page.al` (line 180)
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLines.Page.al` (line 168)

- [ ] **Step 1: Migrate `EcomSalesDocument.Page.al:478`**

Original:
```al
EcomCreateWalletMgt.ShowRelatedWallets(Database::"NPR Ecom Sales Header", Rec.SystemId);
```

Replace with:
```al
EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec);
```

- [ ] **Step 2: Migrate `EcomSalesDocSub.Page.al:180`**

Original:
```al
EcomCreateWalletMgt.ShowRelatedWallets(Database::"NPR Ecom Sales Line", Rec.SystemId);
```

Replace with:
```al
EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec);
```

- [ ] **Step 3: Migrate `EcomSalesLines.Page.al:168`**

Same pattern as Step 2:
```al
EcomCreateWalletMgt.ShowRelatedWalletsAction(Rec);
```

- [ ] **Step 4: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: compile succeeds. All references to the old `ShowRelatedWallets(TableId, SystemId)` are gone.

- [ ] **Step 5: Final sanity grep**

Make sure no stale references remain.

```powershell
# Should return zero matches (or only inside .git/ which is filtered out by Grep tool)
```

Use the Grep tool with pattern `ShowRelatedWallets\(Database::` to confirm no residual untyped callers.

- [ ] **Step 6: Commit Tasks 6 + 7 together**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomCreateWalletMgt.Codeunit.al \
        src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al \
        src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocSub.Page.al \
        src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesLines.Page.al
git commit -m "Refactor Wallet to typed ShowRelatedWalletsAction overloads + extract iterator (CORE-311)"
```

---

## Task 8: Create `NPR Ecom Wallet Sub` page

**Files:**
- Create: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomWalletSub.Page.al`

- [ ] **Step 1: Create the file**

Use `WALLET_SUB_PAGE_ID` from Task 1.

```al
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page <WALLET_SUB_PAGE_ID> "NPR Ecom Wallet Sub"
{
    Caption = 'Wallets';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR AttractionWallet";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer-facing reference number for this wallet.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the wallet description.';
                }
                field(OriginatesFromItemNo; Rec.OriginatesFromItemNo)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number this wallet was created from.';
                }
                field(ExpirationDate; Rec.ExpirationDate)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the wallet expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenWallet)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected wallet to see full details.';

                trigger OnAction()
                var
                    EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
                begin
                    EcomCreateWalletMgt.OpenWalletCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        WalletsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and WalletsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(WalletsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(WalletsJson: JsonArray)
    var
        WalletToken: JsonToken;
        WalletObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
        DateText: Text;
        ParsedDateTime: DateTime;
    begin
        foreach WalletToken in WalletsJson do begin
            WalletObj := WalletToken.AsObject();
            Rec.Init();
            if WalletObj.Get('Ref', FieldToken) then
                Rec.ReferenceNumber := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.ReferenceNumber));
            if WalletObj.Get('Desc', FieldToken) then
                Rec.Description := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.Description));
            if WalletObj.Get('Item', FieldToken) then
                Rec.OriginatesFromItemNo := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec.OriginatesFromItemNo));
            if WalletObj.Get('Exp', FieldToken) then begin
                DateText := FieldToken.AsValue().AsText();
                if (DateText <> '') and Evaluate(ParsedDateTime, DateText, 9) then
                    Rec.ExpirationDate := ParsedDateTime;
            end;
            if WalletObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
```

- [ ] **Step 2: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

- [ ] **Step 3: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/Wallet/EcomWalletSub.Page.al
git commit -m "Add NPR Ecom Wallet Sub subpage (CORE-311)"
```

---

## Task 9: Extend `EcomDocSubpagesTask` orchestrator

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al`

Add 3 `BuildXPayload` + 3 result-key tokens + 3 calls in `OnRun`. Each payload always adds its key (even with empty array) so the parent's `AllSubpagesLoaded` AND-chain succeeds.

- [ ] **Step 1: Add 3 calls in `OnRun`**

After line 24 (`BuildMembershipsPayload(EcomSalesHeader, Result);`), insert:

```al
        BuildTicketsPayload(EcomSalesHeader, Result);
        BuildCouponsPayload(EcomSalesHeader, Result);
        BuildWalletsPayload(EcomSalesHeader, Result);
```

So `OnRun` body becomes:

```al
trigger OnRun()
var
    EcomSalesHeader: Record "NPR Ecom Sales Header";
    Params: Dictionary of [Text, Text];
    Result: Dictionary of [Text, Text];
    HeaderSystemId: Guid;
begin
    Params := Page.GetBackgroundParameters();
    if not Evaluate(HeaderSystemId, Params.Get(HeaderSystemIdParamTok())) then
        exit;
    if not EcomSalesHeader.GetBySystemId(HeaderSystemId) then
        exit;

    BuildVouchersPayload(EcomSalesHeader, Result);
    BuildMembershipsPayload(EcomSalesHeader, Result);
    BuildTicketsPayload(EcomSalesHeader, Result);
    BuildCouponsPayload(EcomSalesHeader, Result);
    BuildWalletsPayload(EcomSalesHeader, Result);

    Page.SetBackgroundTaskResult(Result);
end;
```

- [ ] **Step 2: Add `BuildTicketsPayload` after `BuildMembershipsPayload`**

```al
local procedure BuildTicketsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
var
    TempTicket: Record "NPR TM Ticket" temporary;
    TicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    TicketsJson: JsonArray;
    TicketJson: JsonObject;
    TicketsJsonText: Text;
begin
    TicketImpl.BuildTicketTempBufferForDoc(EcomSalesHeader, TempTicket);
    if TempTicket.FindSet() then
        repeat
            Clear(TicketJson);
            TicketJson.Add('No', TempTicket."No.");
            TicketJson.Add('Ext', TempTicket."External Ticket No.");
            TicketJson.Add('Type', TempTicket."Ticket Type Code");
            TicketJson.Add('Item', TempTicket."Item No.");
            TicketJson.Add('VFromD', Format(TempTicket."Valid From Date", 0, 9));
            TicketJson.Add('VFromT', Format(TempTicket."Valid From Time", 0, 9));
            TicketJson.Add('VToD', Format(TempTicket."Valid To Date", 0, 9));
            TicketJson.Add('VToT', Format(TempTicket."Valid To Time", 0, 9));
            TicketJson.Add('Sid', Format(TempTicket.SystemId, 0, 4));
            TicketsJson.Add(TicketJson);
        until TempTicket.Next() = 0;
    TicketsJson.WriteTo(TicketsJsonText);
    Result.Add(TicketsResultKeyTok(), TicketsJsonText);
end;
```

- [ ] **Step 3: Add `BuildCouponsPayload`**

```al
local procedure BuildCouponsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
var
    TempCoupon: Record "NPR NpDc Coupon" temporary;
    CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    CouponsJson: JsonArray;
    CouponJson: JsonObject;
    CouponsJsonText: Text;
begin
    CouponImpl.BuildCouponTempBufferForDoc(EcomSalesHeader, TempCoupon);
    if TempCoupon.FindSet() then
        repeat
            Clear(CouponJson);
            CouponJson.Add('No', TempCoupon."No.");
            CouponJson.Add('Ref', TempCoupon."Reference No.");
            CouponJson.Add('Type', TempCoupon."Coupon Type");
            CouponJson.Add('Desc', TempCoupon.Description);
            CouponJson.Add('Start', Format(TempCoupon."Starting Date", 0, 9));
            CouponJson.Add('End', Format(TempCoupon."Ending Date", 0, 9));
            CouponJson.Add('Sid', Format(TempCoupon.SystemId, 0, 4));
            CouponsJson.Add(CouponJson);
        until TempCoupon.Next() = 0;
    CouponsJson.WriteTo(CouponsJsonText);
    Result.Add(CouponsResultKeyTok(), CouponsJsonText);
end;
```

- [ ] **Step 4: Add `BuildWalletsPayload`**

```al
local procedure BuildWalletsPayload(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Result: Dictionary of [Text, Text])
var
    TempWallet: Record "NPR AttractionWallet" temporary;
    WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    WalletsJson: JsonArray;
    WalletJson: JsonObject;
    WalletsJsonText: Text;
begin
    WalletMgt.BuildWalletTempBufferForDoc(EcomSalesHeader, TempWallet);
    if TempWallet.FindSet() then
        repeat
            Clear(WalletJson);
            WalletJson.Add('Ref', TempWallet.ReferenceNumber);
            WalletJson.Add('Desc', TempWallet.Description);
            WalletJson.Add('Item', TempWallet.OriginatesFromItemNo);
            WalletJson.Add('Exp', Format(TempWallet.ExpirationDate, 0, 9));
            WalletJson.Add('Sid', Format(TempWallet.SystemId, 0, 4));
            WalletsJson.Add(WalletJson);
        until TempWallet.Next() = 0;
    WalletsJson.WriteTo(WalletsJsonText);
    Result.Add(WalletsResultKeyTok(), WalletsJsonText);
end;
```

- [ ] **Step 5: Add the 3 result-key tokens**

After `MembershipsResultKeyTok()` (line 112-117), add:

```al
internal procedure TicketsResultKeyTok(): Text
var
    ResultKeyTok: Label 'Tickets', Locked = true;
begin
    exit(ResultKeyTok);
end;

internal procedure CouponsResultKeyTok(): Text
var
    ResultKeyTok: Label 'Coupons', Locked = true;
begin
    exit(ResultKeyTok);
end;

internal procedure WalletsResultKeyTok(): Text
var
    ResultKeyTok: Label 'Wallets', Locked = true;
begin
    exit(ResultKeyTok);
end;
```

- [ ] **Step 6: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

- [ ] **Step 7: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_fastLine/virtualItems/EcomDocSubpagesTask.Codeunit.al
git commit -m "Extend orchestrator with Tickets/Coupons/Wallets payload builders (CORE-311)"
```

---

## Task 10: Wire parent page (`EcomSalesDocument.Page.al`)

**Files:**
- Modify: `Application/src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al`

3 changes: add `part(...)` declarations after MembershipsSubPage; add routing in `OnPageBackgroundTaskCompleted`; add `ClearContents` in `ClearAllSubpages`; extend `AllSubpagesLoaded` AND-chain.

- [ ] **Step 1: Add 3 `part(...)` declarations**

After the existing `MembershipsSubPage` part block (lines 310-315), insert:

```al
            part(TicketsSubPage; "NPR Ecom Ticket Sub")
            {
                Caption = 'Tickets';
                ApplicationArea = NPRRetail;
                UpdatePropagation = Both;
            }
            part(CouponsSubPage; "NPR Ecom Coupon Sub")
            {
                Caption = 'Coupons';
                ApplicationArea = NPRRetail;
                UpdatePropagation = Both;
            }
            part(WalletsSubPage; "NPR Ecom Wallet Sub")
            {
                Caption = 'Wallets';
                ApplicationArea = NPRRetail;
                UpdatePropagation = Both;
            }
```

- [ ] **Step 2: Extend `OnPageBackgroundTaskCompleted` routing**

Currently at lines 554-572. The existing body uses an AND-chain with one commented-out line for Tickets. Replace the AND-chain (lines 564-566) with:

```al
        AllSubpagesLoaded := PopulateVouchersSubpage(Results);
        AllSubpagesLoaded := PopulateMembershipsSubpage(Results) and AllSubpagesLoaded;
        AllSubpagesLoaded := PopulateTicketsSubpage(Results) and AllSubpagesLoaded;
        AllSubpagesLoaded := PopulateCouponsSubpage(Results) and AllSubpagesLoaded;
        AllSubpagesLoaded := PopulateWalletsSubpage(Results) and AllSubpagesLoaded;
```

Delete the existing `// AllSubpagesLoaded := PopulateTicketsSubpage(Results) and AllSubpagesLoaded;` comment line.

- [ ] **Step 3: Add 3 `PopulateXSubpage` helpers**

After `PopulateMembershipsSubpage` (line 599-609), add:

```al
    local procedure PopulateTicketsSubpage(Results: Dictionary of [Text, Text]) PayloadPresent: Boolean
    var
        EcomDocSubpagesTask: Codeunit "NPR Ecom Doc Subpages Task";
        PayloadText: Text;
    begin
        PayloadPresent := Results.Get(EcomDocSubpagesTask.TicketsResultKeyTok(), PayloadText);
        if PayloadPresent then
            CurrPage.TicketsSubPage.Page.PopulateFromJsonText(PayloadText)
        else
            CurrPage.TicketsSubPage.Page.ClearContents();
    end;

    local procedure PopulateCouponsSubpage(Results: Dictionary of [Text, Text]) PayloadPresent: Boolean
    var
        EcomDocSubpagesTask: Codeunit "NPR Ecom Doc Subpages Task";
        PayloadText: Text;
    begin
        PayloadPresent := Results.Get(EcomDocSubpagesTask.CouponsResultKeyTok(), PayloadText);
        if PayloadPresent then
            CurrPage.CouponsSubPage.Page.PopulateFromJsonText(PayloadText)
        else
            CurrPage.CouponsSubPage.Page.ClearContents();
    end;

    local procedure PopulateWalletsSubpage(Results: Dictionary of [Text, Text]) PayloadPresent: Boolean
    var
        EcomDocSubpagesTask: Codeunit "NPR Ecom Doc Subpages Task";
        PayloadText: Text;
    begin
        PayloadPresent := Results.Get(EcomDocSubpagesTask.WalletsResultKeyTok(), PayloadText);
        if PayloadPresent then
            CurrPage.WalletsSubPage.Page.PopulateFromJsonText(PayloadText)
        else
            CurrPage.WalletsSubPage.Page.ClearContents();
    end;
```

- [ ] **Step 4: Extend `ClearAllSubpages`**

Current body at lines 611-617. Replace with:

```al
    local procedure ClearAllSubpages()
    begin
        CurrPage.VouchersSubPage.Page.ClearContents();
        CurrPage.MembershipsSubPage.Page.ClearContents();
        CurrPage.TicketsSubPage.Page.ClearContents();
        CurrPage.CouponsSubPage.Page.ClearContents();
        CurrPage.WalletsSubPage.Page.ClearContents();
    end;
```

(Removes the commented-out `// CurrPage.TicketsSubPage.Page.ClearContents();` placeholder.)

- [ ] **Step 5: Verify compile**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: success. All 5 subpages are now wired into the parent page's background-task lifecycle.

- [ ] **Step 6: Commit**

```bash
git add src/_API_SERVICES/ecommerce/incomingEcommerceSalesDocuments/_public/EcomSalesDocument.Page.al
git commit -m "Wire Tickets/Coupons/Wallets subpages into parent Ecom Sales Document (CORE-311)"
```

---

## Task 11: Full build verification

- [ ] **Step 1: Clean compile with all analyzers**

```powershell
cd C:\Projects\npcore\Application
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: compile succeeds. Zero new warnings or errors.

- [ ] **Step 2: Compile with bcdev (BC SaaS target)**

```powershell
bcdev compile -suppressWarnings -generateReportLayout false
```

Expected: compile succeeds.

- [ ] **Step 3: Verify no residual references to old API**

Grep for `ShowRelatedWallets\(` (with open paren only) — should match only the new typed overloads, not the old `(TableId, SystemId)` signature.

Grep for the 5 result key tokens — `VouchersResultKeyTok|MembershipsResultKeyTok|TicketsResultKeyTok|CouponsResultKeyTok|WalletsResultKeyTok` — confirm all 5 are referenced in both the orchestrator (definitions + use in BuildXPayload) and the parent page (the 5 Populate helpers).

- [ ] **Step 4: Verify LSP / IDE has no errors**

If LSP is available (`ENABLE_LSP_TOOL=1`): run `mcp__al-language-server__get_diagnostics_for_file` on each modified file to confirm zero errors/warnings.

---

## Task 12: Manual test on a real BC sandbox

- [ ] **Step 1: Publish to a dev sandbox**

```powershell
bcdev publish
```

Or use VS Code's `Ctrl+F5` for the configured CDX Sandbox launch config.

- [ ] **Step 2: Open an Ecom Sales Document that has all 5 asset types**

Navigate to **NPR Ecom Sales Documents** list → open a document that has linked vouchers, memberships, tickets, coupons, AND wallets.

- [ ] **Step 3: Verify all 5 subpages render**

The parent page should show 5 subpages in order: Vouchers, Memberships, Tickets, Coupons, Wallets. Each should populate within ~1 second (background task completion).

- [ ] **Step 4: Verify Open action on each subpage row**

For each of Tickets, Coupons, Wallets:
- Select a row in the subpage.
- Click the Open action.
- Confirm the correct card opens: `NPR TM Ticket Card`, `NPR NpDc Coupon Card`, `NPR AttractionWalletCard`.

- [ ] **Step 5: Verify line-level count-switch behavior**

On the subpage `NPR Ecom Sales Doc Sub` (lines on the document):
- Find a line with `Virtual Item Process Status = Processed` and Subtype = Ticket. Click AssistEdit on the status field.
  - If 0 tickets linked → message "No tickets are linked to this line."
  - If 1 ticket linked → `NPR TM Ticket Card` opens directly.
  - If 2+ tickets → list opens.
- Repeat for Coupon subtype.
- Find a line with `Attr. Wallet Processing Status = Processed`. Click AssistEdit.
  - Same 0/1/else behavior with wallets.

- [ ] **Step 6: Verify header-level action behavior**

On the main document page:
- Click "Retail Tickets" → list of all tickets opens.
- Click "Retail Coupons" → list of all coupons opens.
- Click "Attraction Wallets" → list of all wallets opens.

Header-level actions do NOT use count-switch — they always open the list (matching Voucher/Membership precedent).

- [ ] **Step 7: Stress test with high-volume document**

Find or create a document with 50+ tickets. Verify:
- The Tickets subpage populates without truncation.
- The background task completes in a reasonable time (< 3 seconds).
- No console / Sentry errors.

- [ ] **Step 8: Navigate between documents — confirm subpages refresh**

Open document A → 5 subpages populate. Open document B → subpages clear then re-populate with B's data. No stale data from A bleeds into B.

- [ ] **Step 9: Edge case — document with NO virtual items**

Open a document with zero linked virtual items. All 5 subpages should be empty (no error, no "loading…" stuck state).

- [ ] **Step 10: No commit required for testing**

This is verification only. If any of the above fail, file the issue and add follow-up tasks before proceeding to PR.

---

## Final commit

After Task 12 passes, the branch contains 8 commits:
1. Allocate page IDs (no commit, just the plan update)
2. Extract Ticket iterators + add OpenTicketCardForSystemId + count-switch (CORE-311)
3. Add NPR Ecom Ticket Sub subpage (CORE-311)
4. Extract Coupon iterators + add OpenCouponCardForSystemId + count-switch (CORE-311)
5. Add NPR Ecom Coupon Sub subpage (CORE-311)
6. Refactor Wallet to typed ShowRelatedWalletsAction overloads + extract iterator (CORE-311)
7. Add NPR Ecom Wallet Sub subpage (CORE-311)
8. Extend orchestrator with Tickets/Coupons/Wallets payload builders (CORE-311)
9. Wire Tickets/Coupons/Wallets subpages into parent Ecom Sales Document (CORE-311)

(Task 1 doesn't produce a commit; Tasks 11–12 are verification only.)

## Codex review of the implementation plan

Per `CLAUDE.md` root-level project rule: after the plan is complete and **before** execution starts, automatically send the plan to codex via `pal:clink` with GPT-5.5 + extra-high reasoning for review. Address any flagged issues before transitioning to execution.
