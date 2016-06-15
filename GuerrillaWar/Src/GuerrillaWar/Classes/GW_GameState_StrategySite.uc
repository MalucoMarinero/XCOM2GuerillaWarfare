
class GW_GameState_StrategySite extends XComGameState_GeoscapeEntity;

struct StrategySiteStructure
{
	var name Type;
	var float Completion; // 0.0 - 1.0
};


var() array<StrategySiteStructure> Structures;

//---------------------------------------------------------------------------------------
//----------- GW_GameState_StrategySite Interface --------------------------------------
//---------------------------------------------------------------------------------------

function int GetStructureCount(name StructureType)
{
	local StrategySiteStructure Structure;
	local int S_Count;
	foreach Structures(Structure)
	{
		if (Structure.Type == StructureType)
		{
			S_Count++;
		}
	}
	return S_Count;
}

function DestroyStructureOfType(name StructureType)
{
	local StrategySiteStructure Structure;
	local int ix;

	ix = Structures.Find('Type', StructureType);
	if (ix != -1)
	{
		Structures.Remove(ix, 1);
	}
}


function GW_GameState_MissionSite SpawnMissionSite(name MissionSourceName, name MissionRewardName, optional name ExtraMissionRewardName)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local GW_GameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_Reward> MissionRewards;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	RegionState = GetWorldRegion();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate(MissionSourceName));
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(MissionRewardName));

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("StrategySite: GenerateMission");
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState);
	RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
	MissionRewards.AddItem(RewardState);

	if(ExtraMissionRewardName != '')
	{
		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(ExtraMissionRewardName));

		if(RewardTemplate != none)
		{
			RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
			NewGameState.AddStateObject(RewardState);
			RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
			MissionRewards.AddItem(RewardState);
		}
	}

	MissionState = GW_GameState_MissionSite(NewGameState.CreateStateObject(class'GW_GameState_MissionSite'));
	NewGameState.AddStateObject(MissionState);
	MissionState.BuildMission(MissionSource, Get2DLocation(), RegionState.GetReference(), MissionRewards);
	MissionState.SiteGenerated = true;
	MissionState.RelatedStrategySiteRef = GetReference();

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

	return MissionState;
}
//---------------------------------------------------------------------------------------
//----------- XComGameState_GeoscapeEntity Implementation -------------------------------
//---------------------------------------------------------------------------------------

protected function bool CanInteract()
{
	return true;
}

//---------------------------------------------------------------------------------------
function bool AboutToExpire()
{
	return false;
}

function class<UIStrategyMapItem> GetUIClass()
{
	return class'UIStrategyMapItem_Mission';
}

function string GetUIWidgetFlashLibraryName()
{
	return string(class'UIPanel'.default.LibID);
}

function string GetUIPinImagePath()
{
	return "";
}

// The static mesh for this entities 3D UI
function StaticMesh GetStaticMesh()
{
	return StaticMesh(`CONTENT.RequestGameArchetype("UI_3D.Overwold_Final.Council_VIP"));
}

// Scale adjustment for the 3D UI static mesh
function vector GetMeshScale()
{
	local vector ScaleVector;

	ScaleVector.X = 0.8;
	ScaleVector.Y = 0.8;
	ScaleVector.Z = 0.8;

	return ScaleVector;
}

function Rotator GetMeshRotator()
{
	local Rotator MeshRotation;

	MeshRotation.Roll = 0;
	MeshRotation.Pitch = 0;
	MeshRotation.Yaw = 0;

	return MeshRotation;
}

function bool ShouldBeVisible()
{
	return true;
}

//function bool ShowFadedPin()
//{
//	return (bNotAtThreshold || bBuilding);
//}

function bool RequiresSquad()
{
	return true;
}


function UpdateGameBoard()
{
}



function RemoveEntity(XComGameState NewGameState)
{
	`assert(false);
}

function string GetUIButtonIcon()
{
	return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
}
