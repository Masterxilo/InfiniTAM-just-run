// Copyright 2014 Isis Innovation Limited and the authors of InfiniTAM

#pragma once

#include <map>

#include "../Engines/Visualisation/Interface/ITMVisualisationEngine.h"
#include "../Objects/RenderStates/ITMRenderState.h"
#include "../Objects/Scene/ITMScene.h"
#include "../Objects/Tracking/ITMTrackingState.h"
#include "../Utils/ITMLibSettings.h"

namespace ITMLib {
	struct ITMPoseConstraint
	{
	public:
		ITMPoseConstraint(void);

		void AddObservation(const ORUtils::SE3Pose & relative_pose, int weight = 1);
		ORUtils::SE3Pose GetAccumulatedInfo(void) const { return accu_poses; }
		int GetNumAccumulatedInfo(void) const { return accu_num; }
	private:
		ORUtils::SE3Pose accu_poses;
		int accu_num;
	};

	template<class TVoxel,class TIndex>
	class ITMLocalScene
	{
	public:
		ITMScene<TVoxel,TIndex> *scene;
		ITMRenderState *renderState;
		ITMTrackingState *trackingState;
		std::map<int,ITMPoseConstraint> relations;

		ITMLocalScene(const ITMLibSettings *settings, const ITMVisualisationEngine<TVoxel,TIndex> *visualisationEngine, const Vector2i & trackedImageSize)
		{
			MemoryDeviceType memoryType = settings->deviceType == ITMLibSettings::DEVICE_CUDA ? MEMORYDEVICE_CUDA : MEMORYDEVICE_CPU;
			scene = new ITMScene<TVoxel,TIndex>(&settings->sceneParams, settings->useSwapping, memoryType);
			renderState = visualisationEngine->CreateRenderState(scene, trackedImageSize);
			trackingState = new ITMTrackingState(trackedImageSize, memoryType);
		}
		~ITMLocalScene(void)
		{
			delete scene;
			delete renderState;
			delete trackingState;
		}

		/** Check whether this is a new scene that has not been
		    completely localised relative to any others.
		*/
/*		bool isNewScene(void) const
		{
			return (relations.size() == 0);
		}*/
	};
}
