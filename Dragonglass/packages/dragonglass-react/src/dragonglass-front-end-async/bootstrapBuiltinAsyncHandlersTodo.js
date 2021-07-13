import { SetView } from "./handlers/SetView";
import { SetCaptions } from "./handlers/SetCaptions";
import { Menu } from "./handlers/Menu";
import { StartTransaction } from "./handlers/StartTransaction";
import { SetFormat } from "./handlers/SetFormat";
import { SetOptions } from "./handlers/SetOptions";
import { SetOption } from "./handlers/SetOption";
import { RefreshData } from "./handlers/RefreshData";
import { ConfigureTheme } from "./handlers/ConfigureTheme";
import { ConfigureFont } from "./handlers/ConfigureFont";
import { RegisterModule } from "./handlers/RegisterModule";
import { SetImage } from "./handlers/SetImage";
import { ReportBug } from "./handlers/ReportBug";
import { UpdateRestaurantLayout } from "./handlers/npre/UpdateRestaurantLayout";
import { UpdateWaiterPadData } from "./handlers/npre/UpdateWaiterPadData";
import { UpdateRestaurantStatuses } from "./handlers/npre/UpdateRestaurantStatuses";
import { SetRestaurant } from "./handlers/npre/SetRestaurant";
import { HardwareInitializationCompleted } from "./handlers/HardwareInitializationCompleted";
import { FrontEndAsyncInterface } from "dragonglass-front-end-async";
import { UpdatePreSearch } from "./handlers/UpdatePreSearch";
import { UpdateSearch } from "./handlers/UpdateSearch";
import { InvokeHardwareConnector } from "./handlers/InvokeHardwareConnector";
import { BalanceSetContext } from "./handlers/BalanceSetContext";

// Bootstrap built-in request handlers
export const bootstrapBuiltinAsyncHandlersTodo = (transcendence) => {
  FrontEndAsyncInterface.register(new SetView(), "SetView");
  FrontEndAsyncInterface.register(new SetCaptions(), "SetCaptions");
  FrontEndAsyncInterface.register(new Menu(), "Menu");
  FrontEndAsyncInterface.register(new StartTransaction(), "StartTransaction");
  FrontEndAsyncInterface.register(new SetFormat(), "SetFormat");
  FrontEndAsyncInterface.register(new SetOptions(), "SetOptions");
  FrontEndAsyncInterface.register(new SetOption(), "SetOption");
  FrontEndAsyncInterface.register(new RefreshData(), "RefreshData");
  FrontEndAsyncInterface.register(new ConfigureTheme(), "ConfigureTheme");
  FrontEndAsyncInterface.register(new ConfigureFont(), "ConfigureFont");
  FrontEndAsyncInterface.register(new RegisterModule(), "RegisterModule");
  FrontEndAsyncInterface.register(new SetImage(), "SetImage");
  FrontEndAsyncInterface.register(new ReportBug(transcendence), "ReportBug"); // TODO: This goes away! Possibly into dragonglass-workflows, belongs mostly there!
  FrontEndAsyncInterface.register(new UpdateRestaurantLayout(), "UpdateRestaurantLayout");
  FrontEndAsyncInterface.register(new UpdateWaiterPadData(), "UpdateWaiterPadData");
  FrontEndAsyncInterface.register(new UpdateRestaurantStatuses(), "UpdateRestaurantStatuses");
  FrontEndAsyncInterface.register(new SetRestaurant(), "SetRestaurant");
  FrontEndAsyncInterface.register(new HardwareInitializationCompleted(), "HardwareInitializationCompleted");
  FrontEndAsyncInterface.register(new UpdatePreSearch(), "UpdatePreSearch");
  FrontEndAsyncInterface.register(new UpdateSearch(), "UpdateSearch");
  FrontEndAsyncInterface.register(new InvokeHardwareConnector(), "InvokeHardwareConnector");
  FrontEndAsyncInterface.register(new BalanceSetContext(), "BalanceSetContext");
};
