state("Ghostrunner-Win64-Shipping", "steam5")
{
    float preciseTime : 0x04328548, 0x1A8, 0x284;
    float levelTime : 0x045A3C20, 0x128, 0x38C;
    float xVel : 0x04328538, 0x30, 0x288, 0xC4;
    float yVel : 0x04328538, 0x30, 0x288, 0xC8;
    bool loading : 0x0445ED38, 0x1E8;
    string250 map : 0x04328548, 0x30, 0xF8, 0x0;
    bool leaderboardShown : 0x04328580, 0x80;
    int deaths : 0x04328548, 0x1A8, 0x28C;
	int killpercp : 0x04328538, 0x30, 0xA4C;
}	

state("Ghostrunner-Win64-Shipping", "gog5")
{
    float preciseTime : 0x04328548, 0x1A8, 0x284;
    float levelTime : 0x045A3C20, 0x128, 0x38C;
	float totalTime : 0x045A3C20, 0x52C;
    float xVel : 0x04328538, 0x30, 0x288, 0xC4;
    float yVel : 0x04328538, 0x30, 0x288, 0xC8;
    bool loading : 0x0445ED38, 0x1E8;
    string250 map : 0x04328548, 0x30, 0xF8, 0x0;
    bool leaderboardShown : 0x04328580, 0x80;
    int deaths : 0x04328548, 0x1A8, 0x28C;
	int killpercp : 0x04328538, 0x30, 0xA4C;
}

startup
{	vars.reachEOL = false;
	vars.lstart = false;
	vars.sec8fight1 = 0;
	vars.sec8fight2 = 0;
	vars.tempestkills = 0;
	vars.nocp = 0;
    vars.fulllvlkills = 0;
	vars.lvlkills = 0;
    vars.endLevelPause = false;
    vars.deathCount = 0;
	vars.killCount = 0;
	vars.killsave = 0;
	vars.watchers = new MemoryWatcherList();
	vars.sections = new int[32, 3] { {0, 511, 0}, {0, 13, 0}, {0, 9, 0}, {0, 0, 0}, {0, 27, 0}, {0, 0, 0}, {0, 10, 0},
	{0, 22, 0}, {0, 21, 0}, {0, 50, 0}, {0, 0, 0}, {0, 2, 0}, {0, 38, 0},
	{0, 0, 0}, {0, 7, 0}, {0, 20, 0}, {0, 1, 0}, {0, 34, 0}, {0, 60, 0},
	{0, 0, 0}, {0, 17, 0}, {0, 1, 0}, {0, 6, 0}, {0, 0, 0}, {0, 39, 0}, {0, 36, 0},
	{0, 0, 0}, {0, 6, 0}, {0, 30, 0}, {0, 61, 0}, {0, 1, 0}, {0, 0, 0}};
	vars.sectionshard = new int[18, 3] { {0, 714, 0}, {0, 26, 0}, 
	{0, 13, 0},	{0, 60, 0}, {0, 38, 0}, {0, 65, 0}, {0, 67, 0},
	{0, 40, 0}, {0, 4, 0}, {0, 48, 0}, {0, 87, 0}, {0, 31, 0}, {0, 5, 0},
	{0, 58, 0}, {0, 65, 0}, {0, 91, 0}, {0, 16, 0}, {0, 0, 0}};

    settings.Add("lvlSplit", true, "Split after completing a level");
    settings.Add("deathcounter", false, "Show Death Counter");
    settings.Add("speedometer", false, "Show Speedometer");
    settings.Add("speedround", false, "Round to whole number", "speedometer");
	settings.Add("killscounter", true, "Show Kills Counter");
	settings.Add("lvlkillscounter", true, "Show Kills on current lvl", "killscounter");
	settings.Add("hardcore", false, "Check for a hardcore run", "killscounter");
    
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show(
            "This game uses RTA w/o Loads as the main timing method.\n"
            + "LiveSplit is currently set to show Real Time (RTA).\n"
            + "Would you like to set the timing method to RTA w/o Loads?",
            "Ghostrunner | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
            var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
            var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
            timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
            textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
            textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }
        if (textSetting != null)
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});

    vars.UpdateSpeedometer = (Action<float, float, bool>)((x, y, round) =>
    {
        double hvel = Math.Floor(Math.Sqrt(x*x + y*y)+0.5);
        if(round)
            vars.SetTextComponent("Speed", Math.Floor(hvel/100).ToString("") + " m/s");
        else
            vars.SetTextComponent("Speed", (hvel/100).ToString("0.00") + " m/s");
    });
}

init
{
	refreshRate = 120;
    int moduleSize = modules.First().ModuleMemorySize;
    switch (moduleSize)
    {
		case 78376960:
            version = "steam5";
            break;	   
		case 78168064:
            version = "gog5";
            break;    
        default:
            version = "Unsupported - " + moduleSize.ToString();
            MessageBox.Show("This game version is currently not supported.", "LiveSplit Auto Splitter - Unsupported Game Version");
            break;
    }
}

isLoading
{
    return (current.loading || vars.endLevelPause || current.map == "/Game/Levels/MainMenu/MainMenu");
}

update
{   string mapn=current.map;
	int section = 0;

	if (version.Contains("Unsupported"))
        return false;

    if(timer.CurrentPhase != TimerPhase.Running || current.loading || current.map == "/Game/Levels/MainMenu/MainMenu")
        vars.endLevelPause = false;

    if (current.leaderboardShown && !old.leaderboardShown && current.map != "/Game/Levels/MainMenu/MainMenu")
        vars.endLevelPause = true;
	
	if (old.loading && current.loading)
		vars.lstart = false;
	
	if (!settings["hardcore"])
	{switch (mapn) {
			case "/Game/Levels/MainMenu/MainMenu":
				vars.cpx=0.0;
				vars.cpy=0.0;
				section = 0;
				break;
			case "/Game/Levels/Tutorial/L_Tutorial_Persistant":
				if (vars.sections[1,2]>0)
				{	section = 2;
				}else
				{ 	section = 1;}
				break;
			case "/Game/Maps/damian_vr4":
				section = 3;
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_01/01_01_World":
				if (vars.sections[4,2]>0 && vars.sections[5,2]>0 && vars.sections[6,2]>0)
				{	section = 7;
				}else
				{ 	section = 4;}
				break;
			case "/Game/Maps/ragis_lvl_vr9_2J":
				section = 5;
				break;	
			case "/Game/Levels/Cyberspace/Furrashu_Tutorial/furasshu_tutorial":
				section = 6;
				break;
			case "/Game/Levels/Industrial/L_Industrial_Persistant":
				section = 8;
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_03/01_03_world":
				if (vars.sections[9,2]>0 && vars.sections[10,2]>0)
				{	section = 11;
				}else
				{ 	section = 9;}
				break;
			case "/Game/Maps/ragis_lvl_vr10_6":
				section = 10;
				break;				
			case "/Game/Levels/01_INDUSTRIAL/01_04/01_04_World":
				section = 12;
				break;
			case "/Game/Levels/Test_Levels/Ld_test/01_04_Cyberspace":
				section = 13;
				break;
			case "/Game/Maps/Force_Push_Tutorial":
				section = 14;
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_05/01_05_World":
				if (vars.sections[15,2]>0)
				{	section = 16;
				}else
				{ 	section = 15;}
				break;
			case "/Game/Levels/02_CYBERCITY/02_01/02_01_world":
				section = 17;
				break;
			case "/Game/Levels/02_CYBERCITY/02_02/02_02_world":
				section = 18;
				break;
			case "/Game/Maps/ragis_lvl_vr5":
				section = 19;
				break;
			case "/Game/Levels/02_CYBERCITY/02_03/02_03_World":
				if (vars.sections[20,2]>0 && vars.sections[22,2]==0)
				{	section = 21;
				} else if (vars.sections[20,2]>0 && vars.sections[22,2]>0)
				{ 	section = 23;
				} else {
					section = 20;
				}
				break;
			case "/Game/Levels/Cyberspace/Nami_Tutorial":
				section = 22;
				break;
			case "/Game/Levels/03_HIGHTECH/03_01/03_01_World":
				section = 24;
				break;
			case "/Game/Levels/03_HIGHTECH/03_02/03_02_world":
				if (vars.sections[25,2]>0 && vars.sections[26,2]>0 && vars.sections[27,2]>0)
				{	section = 28;
				}else
				{ 	section = 25;}
				break;
			case "/Game/Levels/Test_Levels/Ld_test/Cyberspace_Bramki":
				section = 26;
				break;
			case "/Game/Levels/Test_Levels/Ld_test/Mindhacking_Tutorial":
				section = 27;
				break;
			case "/Game/Levels/03_HIGHTECH/03_03/03_03_World":
				section = 29;
				break;
			case "/Game/Levels/03_HIGHTECH/03_04/03_04_world":
				section = 30;
				break;
			case "/Game/Levels/03_HIGHTECH/03_04/Cyberspace_Architect":
				section = 31;
				break;			
	}	
	} else 
	{switch (mapn) {
			case "/Game/Levels/MainMenu/MainMenu":
				vars.cpx=0.0;
				vars.cpy=0.0;
				section = 0;
				break;
			case "/Game/Levels/Tutorial/L_Tutorial_Persistant":
				if (vars.sectionshard[1,2]>0)
				{	section = 2;
				}else
				{ 	section = 1;}
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_01/01_01_World":
				section = 3;
				break;
			case "/Game/Levels/Industrial/L_Industrial_Persistant":
				section = 4;
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_03/01_03_world":
				section = 5;
				break;				
			case "/Game/Levels/01_INDUSTRIAL/01_04/01_04_World":
				section = 6;
				break;
			case "/Game/Levels/01_INDUSTRIAL/01_05/01_05_World":
				if (vars.sectionshard[7,2]>0)
				{	section = 8;
				}else
				{ 	section = 7;}
				break;
			case "/Game/Levels/02_CYBERCITY/02_01/02_01_world":
				section = 9;
				break;
			case "/Game/Levels/02_CYBERCITY/02_02/02_02_world":
				section = 10;
				break;
			case "/Game/Levels/02_CYBERCITY/02_03/02_03_World":
				if (vars.sectionshard[11,2]>0)
				{	section = 12;
				}else
				{ 	section = 11;}
				break;
			case "/Game/Levels/03_HIGHTECH/03_01/03_01_World":
				section = 13;
				break;
			case "/Game/Levels/03_HIGHTECH/03_02/03_02_world":
				section = 14;
				break;
			case "/Game/Levels/03_HIGHTECH/03_03/03_03_World":
				section = 15;
				break;
			case "/Game/Levels/03_HIGHTECH/03_04/03_04_world":
				section = 16;
				break;
			case "/Game/Levels/03_HIGHTECH/03_04/Cyberspace_Architect":
				section = 17;
				break;	
	}
	}
	
	if (old.loading && !current.loading && section>0 && !vars.lstart)
	{	vars.reachEOL = false;
		vars.lstart = true;
		vars.lvlkills = 0;
		if (!settings["hardcore"]) 
		{	vars.fulllvlkills = vars.sections[section,1];
			vars.killCount = vars.sections[0, 0];
		} else 
		{ 	vars.fulllvlkills = vars.sectionshard[section,1];
			vars.killCount = vars.sectionshard[0, 0];
		}
		vars.watchers = new MemoryWatcherList();
		vars.nocp = 0;
		if (!settings["hardcore"])
		{switch (section) {
			case 1:
			case 2:
			case 20:
			case 25:
			case 28:
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 4:		
			case 7:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0xA8, 0x48)) { Name = "cpx" });		
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0xA8, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 6:
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;	
			case 8:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x48, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x48, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(0x045A3C20, 0x98, 0x0, 0x128, 0xA8, 0x2D0, 0x230)) { Name = "fight2" });
				vars.watchers.UpdateAll(game);
				break;
			case 9:
			case 11:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x80, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x80, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 12:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x50, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x50, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 14:
				vars.tempestkills = 0;
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(0x0453D5C0, 0x8, 0x0, 0x298, 0x790, 0x2A0)) { Name = "tempestkills" });
				vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(0x045A3C20, 0x1F8, 0x15C)) { Name = "tempestblocks" });
				vars.watchers.UpdateAll(game);
				break;					
			case 15:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 16:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x50)) { Name = "cpz" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x0445D910, 0x28, 0x3A0, 0x10, 0x2B0, 0xE0, 0x10)) { Name = "tomhealth" });
				vars.watchers.UpdateAll(game);
				break;	
			case 17:
			case 29:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x10, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x10, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 18:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x138, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x138, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);				
				break;
			case 21:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x0445D910, 0x28, 0x398, 0x10, 0x2B0, 0xE0, 0x10)) { Name = "helhealth" });
				vars.watchers.UpdateAll(game);
				break;				
			case 22:
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(0x044D20D0, 0xCB0)) { Name = "surgeblocks" });
				vars.watchers.UpdateAll(game);
				break;		
			case 24:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x18, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x18, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 27:
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x0, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;	
			case 30:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x8, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x8, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x0445D910, 0x28, 0x380, 0x10, 0x2B0, 0xE0, 0x10)) { Name = "marahealth" });
				vars.watchers.UpdateAll(game);
				break;
				
				
			default:
				vars.nocp = 1;
				break;	
		}
		switch (section) {
			case 4:
				vars.fulllvlkills += vars.sections[7,1];
				break;
			case 7:
				vars.fulllvlkills += vars.sections[4,1];
				vars.lvlkills = vars.sections[4,0];
				break;
			case 9:
				vars.fulllvlkills += vars.sections[11,1];
				break;
			case 11:
				vars.fulllvlkills += vars.sections[9,1];
				vars.lvlkills = vars.sections[9,0];
				break;	
			case 25:
				vars.fulllvlkills += vars.sections[28,1];
				break;
			case 28:
				vars.fulllvlkills += vars.sections[25,1];
				vars.lvlkills = vars.sections[25,0];
				break;	
		}
		} else 
		{switch (section) {
			case 1:
			case 2:
			case 11:
			case 12:
			case 14:
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x28, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 3:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0xA8, 0x48)) { Name = "cpx" });		
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0xA8, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 4:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x48, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x48, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 5:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x80, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x80, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 6:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x50, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x50, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 7:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x4C)) { Name = "cpy" });
				vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(0x045A3C20, 0x128, 0x388)) { Name = "alldeaths" });
				vars.watchers.UpdateAll(game);
				break;			
			case 8:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x60, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 9:
			case 15:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x10, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x10, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 10:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x138, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x138, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);				
				break;
			case 13:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x18, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x18, 0x4C)) { Name = "cpy" });
				vars.watchers.UpdateAll(game);
				break;
			case 16:	
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x8, 0x48)) { Name = "cpx" });
				vars.watchers.Add(new MemoryWatcher<float>(new DeepPointer(0x04326CF8, 0x28, 0x8, 0x4C)) { Name = "cpy" });	
				vars.watchers.UpdateAll(game);
				break;
			default:
				vars.nocp = 1;
				break;
		}
		
		} 
	}
	if (current.loading && old.loading)
	{	vars.nocp =1;}
	
	if (vars.nocp == 0 && !old.loading && !current.loading){
		vars.watchers.UpdateAll(game);}
	
	//if (section == 0)
	//	vars.fulllvlkills = 0;	
	
	if (settings["hardcore"] && vars.watchers["cpx"].Current == 48598.09345f && vars.watchers["cpy"].Current == -67505.91406f && section == 7)
	{	if (vars.watchers["alldeaths"].Current == vars.watchers["alldeaths"].Old+1)
		{	vars.sec8fight1 = current.killpercp;
			vars.killCount = current.killpercp-vars.sec8fight1;
			vars.lvlkills = current.killpercp-vars.sec8fight1;
			
		}
	}
	
	if(current.killpercp > old.killpercp && !current.loading)
    {   vars.killCount += current.killpercp-old.killpercp;
		vars.lvlkills += current.killpercp-old.killpercp;
		if (!settings["hardcore"] && section == 27 && vars.lvlkills >= 6)
		{	vars.killCount = vars.sections[0, 0]+6;
			vars.lvlkills = 6;
			vars.killsave = current.killpercp;
		}
		if (section == 8 && vars.watchers["fight2"].Current == 0 && vars.watchers["fight2"].Old == 1 && !settings["hardcore"])
		{	vars.sec8fight2 = 4;}
	}		

	if(current.killpercp > 0 && (vars.watchers["cpx"].Current != vars.watchers["cpx"].Old || vars.watchers["cpy"].Current != vars.watchers["cpy"].Old))
		vars.killsave = current.killpercp;
	
	if(current.killpercp > 0 && (current.levelTime == current.preciseTime && current.preciseTime != old.preciseTime && current.preciseTime > 0.0f))
		vars.killsave = current.killpercp;	
		
	if(current.killpercp == 0 && old.killpercp > 0 && !current.loading)	
	{	vars.killCount += vars.killsave-old.killpercp;
		vars.lvlkills += vars.killsave-old.killpercp;
		if (section == 8 && vars.watchers["fight2"].Current == 4 && vars.sec8fight2 == 4 && !settings["hardcore"])
		{	vars.killCount += vars.sec8fight2;
			vars.lvlkills += vars.sec8fight2;
			vars.sec8fight2 = 0 ;
		}
		
	}
    if(current.killpercp == 0 && old.killpercp > 0 && !current.loading)	
		vars.killsave = 0;

	if (!settings["hardcore"] && section == 14)
	{	if (vars.watchers["tempestblocks"].Current >= vars.watchers["tempestkills"].Current)
		{ 	vars.lvlkills = vars.watchers["tempestblocks"].Current;
		} else {
			vars.lvlkills = vars.watchers["tempestkills"].Current;
		}
		if (vars.lvlkills > vars.tempestkills)
			vars.killCount += vars.lvlkills - vars.tempestkills;
		vars.tempestkills = vars.lvlkills;
	}
	
	if (!settings["hardcore"] && section == 16)
	{	if (vars.watchers["cpx"].Current == 55920.62891f && vars.watchers["cpy"].Current == 25733.92188f && vars.watchers["cpz"].Current == -20644.0f && vars.watchers["tomhealth"].Current <= 0.112f && vars.lvlkills == 0)
		{ 	vars.lvlkills += 1;
			vars.killCount += 1;}
	}
	
	if (!settings["hardcore"] && section == 21)
	{	if (vars.watchers["helhealth"].Current == 0.0f && vars.watchers["helhealth"].Old == 0.25f && vars.lvlkills == 0)
		{ 	vars.lvlkills += 1;
			vars.killCount += 1;}
	}
	
	if (!settings["hardcore"] && section == 22)
	{	if (vars.watchers["surgeblocks"].Current == 2 && vars.lvlkills == 0)
		{ 	vars.lvlkills += 1;
			vars.killCount += 1;}
		if (vars.watchers["surgeblocks"].Current > 2 && vars.watchers["surgeblocks"].Old == 2 && vars.lvlkills == 1)
		{ 	vars.lvlkills += 2;
			vars.killCount += 2;}	
		if (vars.watchers["surgeblocks"].Current > 4 && vars.watchers["surgeblocks"].Old == 4 && vars.lvlkills == 3)
		{ 	vars.lvlkills += 3;
			vars.killCount += 3;}		
	}
	
	if (!settings["hardcore"] && section == 30)
	{	if (vars.watchers["marahealth"].Current == 0.0f && vars.watchers["marahealth"].Old == 0.3300000131f && vars.lvlkills == 0)
		{ 	vars.lvlkills += 1;
			vars.killCount += 1;}
	}

    if(current.deaths == old.deaths + 1 && current.preciseTime > 0.0f)
        vars.deathCount += 1;

	if (current.levelTime == current.preciseTime && current.preciseTime != old.preciseTime && current.preciseTime > 0.0f)
	{	vars.lstart = false;
		if (!settings["hardcore"])
		{	vars.sections[section,0] = vars.lvlkills;
			vars.sections[section,2] = 1;
			vars.sections[0, 0] = vars.killCount;
			if(section == 1 || section == 7 || section == 8 || section == 11 || section == 16 || section == 17 || section == 23 || section == 24 || section == 28 || section == 29 || section == 30)
				vars.reachEOL = true;
		} else 
		{	vars.sectionshard[section,0] = vars.lvlkills;
			vars.sectionshard[section,2] = 1;
			vars.sectionshard[0, 0] = vars.killCount;
			if(section == 2 || section == 7 || section == 11 || section == 17)
			{}else{vars.reachEOL=true;}
		}	
	}
	
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.deathCount = 0;	
	}

    if(settings["speedometer"])
        vars.UpdateSpeedometer(current.xVel, current.yVel, settings["speedround"]);

    if(settings["deathcounter"])
        vars.SetTextComponent("Deaths", (vars.deathCount).ToString());
		

	if(settings["killscounter"])
	{	if (!settings["hardcore"])
		{	vars.SetTextComponent("Kills", (vars.killCount).ToString()+"/"+(vars.sections[0,1]).ToString());
		} else
		{	vars.SetTextComponent("Kills", (vars.killCount).ToString()+"/"+(vars.sectionshard[0,1]).ToString());}
	}	
	if(settings["lvlkillscounter"])
        vars.SetTextComponent("Kills on current lvl", (vars.lvlkills).ToString()+"/"+(vars.fulllvlkills).ToString());	
	

}

start
{	vars.reachEOL = false;
	vars.lstart = false;
	vars.sec8fight1 = 0;
	vars.sec8fight2 = 0;
	vars.tempestkills = 0;
    vars.endLevelPause = false;
    vars.deathCount = 0;
	vars.killCount = 0;
	vars.killsave = 0;
	vars.sections = new int[32, 3] { {0, 511, 0}, {0, 13, 0}, {0, 9, 0}, {0, 0, 0}, {0, 27, 0}, {0, 0, 0}, {0, 10, 0},
	{0, 22, 0}, {0, 21, 0}, {0, 50, 0}, {0, 0, 0}, {0, 2, 0}, {0, 38, 0},
	{0, 0, 0}, {0, 7, 0}, {0, 20, 0}, {0, 1, 0}, {0, 34, 0}, {0, 60, 0},
	{0, 0, 0}, {0, 17, 0}, {0, 1, 0}, {0, 6, 0}, {0, 0, 0}, {0, 39, 0}, {0, 36, 0},
	{0, 0, 0}, {0, 6, 0}, {0, 30, 0}, {0, 61, 0}, {0, 1, 0}, {0, 0, 0}};
	vars.sectionshard = new int[18, 3] { {0, 714, 0}, {0, 26, 0}, 
	{0, 13, 0},	{0, 60, 0}, {0, 38, 0}, {0, 65, 0}, {0, 67, 0},
	{0, 40, 0}, {0, 4, 0}, {0, 48, 0}, {0, 87, 0}, {0, 31, 0}, {0, 5, 0},
	{0, 58, 0}, {0, 65, 0}, {0, 91, 0}, {0, 16, 0}, {0, 0, 0}};
	return (old.preciseTime == 0 && current.preciseTime > 0 && current.map == "/Game/Levels/Tutorial/L_Tutorial_Persistant");

}

split
{
    if (current.leaderboardShown && !old.leaderboardShown && current.map != "/Game/Levels/MainMenu/MainMenu" && settings["lvlSplit"])
	{	vars.reachEOL = false;
		return true;
	}	
	if(vars.reachEOL && (current.loading || vars.endLevelPause || current.map == "/Game/Levels/MainMenu/MainMenu") && settings["lvlSplit"])	
	{	vars.reachEOL = false;
		return true;
	}
	
    if (current.map == "/Game/Levels/03_HIGHTECH/03_04/Cyberspace_Architect" && current.levelTime > old.levelTime && old.levelTime != 0.0f)
        return true;
}

exit
{
    timer.IsGameTimePaused = true;
    vars.endLevelPause = true;
	vars.lstart = false;
	vars.reachEOL = false;
}
