package main

import (
	"log"
	"net"
	"os"

	pb "github.com/bege13mot/vessel-service/proto/vessel"
	"google.golang.org/grpc"
)

const (
	defaultGrpcAddr = ":50053"
	defaultDbHost   = "localhost:27017"

	defaultConsulAddr = "localhost:8500"
)

var (
	// Get database details from environment variables
	dbHost     = os.Getenv("DB_HOST")
	grpcAddr   = os.Getenv("GRPC_ADDR")
	consulAddr = os.Getenv("CONSUL_ADDR")

	// BuildTime is a time label of the moment when the binary was built
	BuildTime = "unset"
	// Version is a last commit hash at the moment when the binary was built
	Version = "unset"
	// Branch name
	Branch = "unset"
)

func initVar() {
	if dbHost == "" {
		log.Println("Use default DB connection settings")

		dbHost = defaultDbHost
	}

	if grpcAddr == "" {
		log.Println("Use default GRPC connection settings")
		grpcAddr = defaultGrpcAddr
	}

	if consulAddr == "" {
		log.Println("Use default Consul connection settings")
		consulAddr = defaultConsulAddr
	}

	log.Printf(
		"Starting the service...\ncommit: %s, build time: %s, release: %s",
		Version, BuildTime, Branch,
	)
}

func createDummyData(repo repository) {
	defer repo.close()
	vessels := []*pb.Vessel{
		{Id: "vessel001", Name: "Kane's Salty Secret", MaxWeight: 200000, Capacity: 500},
	}
	for _, v := range vessels {
		repo.create(v)
	}
}

func main() {

	initVar()

	session, err := CreateSession(dbHost)
	defer session.Close()

	if err != nil {
		log.Fatalf("Error connecting to MongoDB: %v, host: %v", err, dbHost)
	}

	repo := &vesselRepository{session.Copy()}

	createDummyData(repo)

	// Set-up our gRPC server.
	lis, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		log.Fatalf("Failed to listen gRPC: %v", err)
	}
	s := grpc.NewServer()

	// Register our service with the gRPC server, this will tie our
	// implementation into the auto-generated interface code for our
	// protobuf definitio
	pb.RegisterVesselServiceServer(s, &service{session})

	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to serve gRPC: %v", err)
	}
}
