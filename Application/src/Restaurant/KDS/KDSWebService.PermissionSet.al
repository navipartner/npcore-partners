#if NOT BC17
permissionset 6014405 "NPR KDS WebService"
{
    Assignable = true;
    Caption = 'KDS WebService';
    IncludedPermissionSets = "D365 AUTOMATION";
    Access = Internal;

    Permissions =
        codeunit "NPR KDS Frontend Assistant" = X,
        codeunit "NPR KDS Frontend Assist. Impl." = X,
        codeunit "NPR NPRE Restaur. Setup Proxy" = X,
        codeunit "NPR NPRE Notification Handler" = X,
        codeunit "NPR NPRE Kitchen Order Mgt." = X,
        codeunit "NPR Job Queue Management" = X,
        codeunit "NPR NPRE Waiter Pad Mgt." = X,
        codeunit "NPR NPRE Restaurant Print" = X,
        codeunit "NPR NPRE Seating Mgt." = X,
        tabledata "NPR NPRE Kitchen Order" = RIM,
        tabledata "NPR NPRE Kitchen Request" = RIM,
        tabledata "NPR NPRE Kitchen Req. Station" = RIM,
        tabledata "NPR NPRE Kitchen Req. Modif." = RIM,
        tabledata "NPR NPRE Kitchen Req.Src. Link" = RIM,
        tabledata "NPR NPRE Kitchen Station Slct." = R,
        tabledata "NPR NPRE Notification Entry" = RIM,
        tabledata "NPR NPRE Notification Setup" = R,
        tabledata "NPR NPRE Restaurant" = R,
        tabledata "NPR NPRE Restaurant Setup" = R,
        tabledata "NPR NPRE Seating" = RM,
        tabledata "NPR NPRE Seating Location" = R,
        tabledata "NPR NPRE Serv.Flow Profile" = R,
        tabledata "NPR NPRE Flow Status" = R,
        tabledata "NPR NPRE Print/Prod. Cat." = R,
        tabledata "NPR NPRE Assigned Flow Status" = R,
        tabledata "NPR NPRE Assign. Print Cat." = R,
        tabledata "NPR NPRE Seat.: WaiterPadLink" = RM,
        tabledata "NPR NPRE Waiter Pad" = RM,
        tabledata "NPR NPRE Waiter Pad Line" = RMD,
        tabledata "NPR NPRE W.Pad.Line Outp.Buf." = RIMD,
        tabledata "NPR NPRE W.Pad.Line Out.Buffer" = RIMD,
        tabledata "NPR NPRE W.Pad Prnt LogEntry" = RIM,
        tabledata "NPR POS Info NPRE Waiter Pad" = RMD,
        query "NPR NPRE Kitchen Req. Stations" = X,
        query "NPR NPRE Kitchen Req. w Source" = X,
        query "NPR NPRE Kitch.Req.Src. by Doc" = X;
}
#endif