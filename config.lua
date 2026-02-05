Config = {}

-- Prix pour passer le code de la route
Config.CodePrice = 500

-- Prix pour passer les permis
Config.PermisPrice = {
    car = 1500,
    moto = 1200,
    truck = 2000
}

-- Nombre de fautes maximum pour le code (3 = échec à la 3ème faute)
Config.MaxCodeErrors = 3

-- Nombre d'erreurs maximum pour les permis (5 = échec à la 5ème erreur)
Config.MaxPermisErrors = 5

-- Position de l'auto-école (NPC + Menu)
Config.SchoolPosition = vector3(223.25, 373.10, 106.37)
Config.SchoolHeading = 200.0

-- Position de spawn du véhicule pour le permis voiture
Config.VehicleSpawn = {
    car = vector4(178.57, 387.75, 108.96, 260.87),
    moto = vector4(175.57, 387.75, 108.96, 260.87),
    truck = vector4(172.57, 387.75, 108.96, 260.87)
}

-- Modèles des véhicules utilisés pour les permis
Config.VehicleModel = {
    car = 'blista',
    moto = 'bagger',
    truck = 'phantom'
}

-- Nom des items de permis (ox_inventory)
Config.LicenseItem = {
    car = 'card_driver_license',
    moto = 'card_moto_license',
    truck = 'card_truck_license'
}

-- Questions du code de la route
Config.CodeQuestions = {
    {
        question = "Quelle est la limitation de vitesse en agglomération ?",
        answers = {
            {text = "30 km/h", correct = false},
            {text = "50 km/h", correct = true},
            {text = "70 km/h", correct = false}
        }
    },
    {
        question = "À un feu orange, vous devez :",
        answers = {
            {text = "Accélérer pour passer", correct = false},
            {text = "Vous arrêter si vous pouvez le faire en sécurité", correct = true},
            {text = "Continuer sans ralentir", correct = false}
        }
    },
    {
        question = "Le taux d'alcoolémie maximum autorisé est de :",
        answers = {
            {text = "0.2 g/L", correct = false},
            {text = "0.5 g/L", correct = true},
            {text = "0.8 g/L", correct = false}
        }
    },
    {
        question = "Sur autoroute, la vitesse maximale est de :",
        answers = {
            {text = "110 km/h", correct = false},
            {text = "130 km/h", correct = true},
            {text = "150 km/h", correct = false}
        }
    },
    {
        question = "Un panneau triangulaire rouge et blanc signifie :",
        answers = {
            {text = "Interdiction", correct = false},
            {text = "Danger", correct = true},
            {text = "Obligation", correct = false}
        }
    },
    {
        question = "À une intersection sans signalisation, la priorité est :",
        answers = {
            {text = "À gauche", correct = false},
            {text = "À droite", correct = true},
            {text = "Au plus rapide", correct = false}
        }
    },
    {
        question = "La distance de sécurité recommandée est de :",
        answers = {
            {text = "1 seconde", correct = false},
            {text = "2 secondes", correct = true},
            {text = "5 secondes", correct = false}
        }
    },
    {
        question = "Le téléphone au volant est :",
        answers = {
            {text = "Autorisé avec kit mains-libres", correct = false},
            {text = "Interdit même avec kit mains-libres", correct = true},
            {text = "Autorisé à l'arrêt", correct = false}
        }
    },
    {
        question = "Un piéton s'engage sur un passage clouté, vous devez :",
        answers = {
            {text = "Continuer, il doit attendre", correct = false},
            {text = "Vous arrêter pour le laisser passer", correct = true},
            {text = "Klaxonner pour qu'il se dépêche", correct = false}
        }
    },
    {
        question = "La ceinture de sécurité est obligatoire :",
        answers = {
            {text = "Seulement sur autoroute", correct = false},
            {text = "Pour tous les passagers", correct = true},
            {text = "Seulement pour le conducteur", correct = false}
        }
    }
}

-- Points de passage pour le permis VOITURE
-- Chaque checkpoint peut avoir une vitesse maximale personnalisée
Config.PermisCheckpoints = {
    car = {
        {pos = vector3(215.33, 369.97, 106.33), maxSpeed = 50},
        {pos = vector3(402.37, 300.58, 103.01), maxSpeed = 50},
        {pos = vector3(546.24, 248.89, 103.11), maxSpeed = 70},
        {pos = vector3(912.82, 519.16, 120.65), maxSpeed = 70},
        {pos = vector3(989.67, 310.09, 84.08), maxSpeed = 90},
        {pos = vector3(538.68, -314.32, 43.61), maxSpeed = 70},
        {pos = vector3(251.00, -218.08, 54.00), maxSpeed = 50},
        {pos = vector3(272.68, -103.95, 70.04), maxSpeed = 50},
        {pos = vector3(140.82, -29.43, 67.60), maxSpeed = 50},
        {pos = vector3(-24.02, 30.75, 71.94), maxSpeed = 50}
    },
    
    -- Points de passage pour le permis MOTO
    moto = {
        {pos = vector3(215.33, 369.97, 106.33), maxSpeed = 50},
        {pos = vector3(402.37, 300.58, 103.01), maxSpeed = 60},
        {pos = vector3(546.24, 248.89, 103.11), maxSpeed = 80},
        {pos = vector3(912.82, 519.16, 120.65), maxSpeed = 80},
        {pos = vector3(989.67, 310.09, 84.08), maxSpeed = 100},
        {pos = vector3(538.68, -314.32, 43.61), maxSpeed = 80},
        {pos = vector3(251.00, -218.08, 54.00), maxSpeed = 60},
        {pos = vector3(272.68, -103.95, 70.04), maxSpeed = 50},
        {pos = vector3(140.82, -29.43, 67.60), maxSpeed = 50},
        {pos = vector3(-24.02, 30.75, 71.94), maxSpeed = 50}
    },
    
    -- Points de passage pour le permis CAMION
    truck = {
        {pos = vector3(215.33, 369.97, 106.33), maxSpeed = 40},
        {pos = vector3(402.37, 300.58, 103.01), maxSpeed = 40},
        {pos = vector3(546.24, 248.89, 103.11), maxSpeed = 50},
        {pos = vector3(912.82, 519.16, 120.65), maxSpeed = 60},
        {pos = vector3(989.67, 310.09, 84.08), maxSpeed = 70},
        {pos = vector3(538.68, -314.32, 43.61), maxSpeed = 60},
        {pos = vector3(251.00, -218.08, 54.00), maxSpeed = 50},
        {pos = vector3(272.68, -103.95, 70.04), maxSpeed = 40},
        {pos = vector3(140.82, -29.43, 67.60), maxSpeed = 40},
        {pos = vector3(-24.02, 30.75, 71.94), maxSpeed = 40}
    }
}