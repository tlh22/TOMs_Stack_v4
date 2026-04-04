--
DROP INDEX IF EXISTS idx_SurveyID_GeometryID;
CREATE INDEX IF NOT EXISTS idx_SurveyID_GeometryID ON VRMs (SurveyID, GeometryID);

DROP INDEX IF EXISTS idx_SurveyID_GeometryID_PositionID;
CREATE INDEX IF NOT EXISTS idx_SurveyID_GeometryID_PositionID ON VRMs (SurveyID, GeometryID, PositionID)