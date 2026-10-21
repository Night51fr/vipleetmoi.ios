# Viple & Moi — Application iOS Officielle (`com.viplenetwork.vipleetmoi`)

**Viple & Moi** est l'application iOS officielle de gestion de votre espace client **Viple** (Famille & Pro), de vos offres **Agence IT & Télécom**, de vos contrats **Viple Contractuel** et de votre bibliothèque **Livria**.

## Fonctionnalités Clés

1. **Gestion Multi-Profils (Famille & Pro)** :
   - Créez des profils supplémentaires rattachés à votre compte **Viple Live ID** (ex. le prénom de votre fils, d'un conjoint ou d'un collaborateur).
   - Touchez le prénom d'un profil dans la barre supérieure pour basculer instantanément sur ses lignes, son suivi conso en temps réel et ses services attribués.

2. **Mes Services & Suivi Conso (`Agence IT & Télécom`)** :
   - **Forfait Mobile** : jauge animée de consommation Data 5G/4G (Go utilisés / Go inclus), appels, SMS/MMS, hors-forfait et date de renouvellement.
   - **Box 5G** : suivi de votre accès Internet Très Haut Débit 5G et de vos équipements (aucune offre fibre, uniquement des Box 5G selon vos besoins).
   - **Téléphonie SIP** : gestion de vos lignes fixes et trunks voix IP.
   - **Décodeur TV** : gestion de vos boîtiers TV et bouquets.
   - **Hébergement Web & Serveurs** : suivi de vos serveurs dédiés, VPS, domaines et hébergements web.
   - **Infogérance** : suivi de la maintenance, supervision et sécurité de votre parc.
   - **Création Web & Logiciels** : suivi de vos projets d'applications sur mesure.
   - Attribution en 1 tap d'une ligne ou d'un service à n'importe quel profil de la famille ou de l'équipe.

3. **Viple Contractuel (Contrats & Signature tactile)** :
   - Consultez vos contrats en attente et vos contrats signés.
   - Signez vos contrats directement au doigt depuis votre iPhone ou iPad avec horodatage et enregistrement immédiat.

4. **Livria (Ma Bibliothèque & Mes Commandes)** :
   - Retrouvez tous vos livres, mangas et BD enregistrés dans votre bibliothèque Livria, filtrez par statut (*En cours*, *À lire*, *Terminés*) et mettez à jour votre progression de lecture.
   - Suivez vos commandes Livria Store et vos expéditions UPS en temps réel.

5. **Mon Compte Viple Live ID** :
   - Gérez vos coordonnées personnelles et professionnelles, vos profils Famille / Équipe et votre sécurité.

## Architecture & Backends

- **Aucune donnée de démonstration** : toutes les données proviennent exclusivement des bases SQL Server de production.
- **Serveur Espace Client V2 dédié** : `https://espace-client-v2.viplenetwork.com` (`/api/v1/espace-client/*`) avec bascule haute disponibilité sur `https://api.viple.digital`.
- **Compatibilité** : iOS 17.0+ (iPhone & iPad avec support complet du multitâche iPad toutes orientations).
