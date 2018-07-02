package main

import (
	pb "github.com/bege13mot/vessel-service/proto/vessel"
	"golang.org/x/net/context"
	"gopkg.in/mgo.v2"
)

// Our gRPC service handler
type service struct {
	session *mgo.Session
}

func (s *service) GetRepo() repository {
	return &vesselRepository{s.session.Clone()}
}

func (s *service) FindAvailable(ctx context.Context, req *pb.Specification) (*pb.Response, error) {
	defer s.GetRepo().close()
	// Find the next available vessel
	vessel, err := s.GetRepo().findAvailable(req)
	if err != nil {
		return nil, err
	}

	// Set the vessel as part of the response message type
	return &pb.Response{Vessel: vessel}, nil
}

func (s *service) Create(ctx context.Context, req *pb.Vessel) (*pb.Response, error) {
	defer s.GetRepo().close()
	if err := s.GetRepo().create(req); err != nil {
		return nil, err
	}

	return &pb.Response{Created: true, Vessel: req}, nil
}
