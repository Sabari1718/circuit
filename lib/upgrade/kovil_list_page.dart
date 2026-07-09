import 'package:flutter/material.dart';

class PlaceOfWorship {
  final String id;
  final String name;
  final String location;
  final String description;
  final String type;
  final Color themeColor;
  final String imageUrl;

  const PlaceOfWorship({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.type,
    required this.themeColor,
    required this.imageUrl,
  });
}

class KovilListPage extends StatefulWidget {
  final String religion;

  const KovilListPage({super.key, required this.religion});

  @override
  State<KovilListPage> createState() => _KovilListPageState();
}

class _KovilListPageState extends State<KovilListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<PlaceOfWorship> get _allPlaces {
    if (widget.religion == "Hindu") {
      return const [
        PlaceOfWorship(
          id: '1',
          name: 'Sri Meenakshi Amman Temple',
          location: 'Madurai, TN',
          description: 'Historic Hindu temple located on the southern bank of the Vaigai River. Donate for daily pooja and annadanam.',
          type: 'Temple',
          themeColor: Color(0xFFEA580C),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/e/e9/An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg/960px-An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg&w=800&output=webp',
        ),
        PlaceOfWorship(
          id: '2',
          name: 'Brihadeeswarar Temple',
          location: 'Thanjavur, TN',
          description: 'A Hindu temple dedicated to Shiva. Support the heritage preservation and temple maintenance.',
          type: 'Temple',
          themeColor: Color(0xFFEA580C),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Brihadisvara_Temple_during_Maha_Shivaratri-WUS03611_%28edit%29.jpg/960px-Brihadisvara_Temple_during_Maha_Shivaratri-WUS03611_%28edit%29.jpg&w=800&output=webp',
        ),
        PlaceOfWorship(
          id: '3',
          name: 'Arulmigu Ramanathaswamy',
          location: 'Rameswaram, TN',
          description: 'A Hindu temple dedicated to the god Shiva located on Rameswaram island.',
          type: 'Temple',
          themeColor: Color(0xFFEA580C),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/8/84/Ramanathaswamy_temple7.JPG/960px-Ramanathaswamy_temple7.JPG&w=800&output=webp',
        ),
      ];
    } else if (widget.religion == "Muslim") {
      return const [
        PlaceOfWorship(
          id: '4',
          name: 'Mecca Masjid',
          location: 'Hyderabad, TS',
          description: 'One of the oldest mosques in India. Contribute to community welfare and charitable activities.',
          type: 'Mosque',
          themeColor: Color(0xFF059669),
          imageUrl: 'https://images.unsplash.com/photo-1564121211835-e88c852648ab?q=80&w=800&auto=format&fit=crop',
        ),
        PlaceOfWorship(
          id: '5',
          name: 'Jama Masjid',
          location: 'New Delhi, DL',
          description: 'One of the largest mosques in India. Support local education and health camps organized by the committee.',
          type: 'Mosque',
          themeColor: Color(0xFF059669),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Jama_Masjid_-_In_the_Noon.jpg/960px-Jama_Masjid_-_In_the_Noon.jpg&w=800&output=webp',
        ),
      ];
    } else if (widget.religion == "Christian") {
      return const [
        PlaceOfWorship(
          id: '6',
          name: 'San Thome Basilica',
          location: 'Chennai, TN',
          description: 'A Catholic minor basilica. Join us in our weekly community service and donations for the underprivileged.',
          type: 'Church',
          themeColor: Color(0xFF2563EB),
          imageUrl: 'https://images.unsplash.com/photo-1548625361-9c6bc014897f?q=80&w=800&auto=format&fit=crop',
        ),
        PlaceOfWorship(
          id: '7',
          name: 'Basilica of Bom Jesus',
          location: 'Goa',
          description: 'UNESCO World Heritage Site. Contribute to our charity programs supporting local children.',
          type: 'Church',
          themeColor: Color(0xFF2563EB),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Front_Elevation_of_Basilica_of_Bom_Jesus.jpg/960px-Front_Elevation_of_Basilica_of_Bom_Jesus.jpg&w=800&output=webp',
        ),
      ];
    } else if (widget.religion == "Sikh") {
      return const [
        PlaceOfWorship(
          id: '8',
          name: 'Golden Temple',
          location: 'Amritsar, PB',
          description: 'The preeminent spiritual site of Sikhism. Support the langar (community kitchen) serving thousands daily.',
          type: 'Gurdwara',
          themeColor: Color(0xFFD97706),
          imageUrl: 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/94/The_Golden_Temple_of_Amrithsar_7.jpg/960px-The_Golden_Temple_of_Amrithsar_7.jpg&w=800&output=webp',
        ),
      ];
    } else {
      return [
        PlaceOfWorship(
          id: '9',
          name: '${widget.religion} Community Center',
          location: 'Central District',
          description: 'Local gathering place for the ${widget.religion} community. Support our ongoing social initiatives.',
          type: 'Center',
          themeColor: const Color(0xFF7C3AED),
          imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=800&auto=format&fit=crop',
        ),
      ];
    }
  }

  List<PlaceOfWorship> get _filteredPlaces {
    if (_searchQuery.isEmpty) return _allPlaces;
    final q = _searchQuery.toLowerCase();
    return _allPlaces
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q))
        .toList();
  }

  String _getHeaderImage(String religion) {
    switch (religion) {
      case 'Hindu':
        return 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/e/e9/An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg/960px-An_aerial_view_of_Madurai_city_from_atop_of_Meenakshi_Amman_temple.jpg&w=800&output=webp';
      case 'Muslim':
        return 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Jama_Masjid_-_In_the_Noon.jpg/960px-Jama_Masjid_-_In_the_Noon.jpg&w=800&output=webp';
      case 'Christian':
        return 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Front_Elevation_of_Basilica_of_Bom_Jesus.jpg/960px-Front_Elevation_of_Basilica_of_Bom_Jesus.jpg&w=800&output=webp';
      case 'Sikh':
        return 'https://wsrv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/94/The_Golden_Temple_of_Amrithsar_7.jpg/960px-The_Golden_Temple_of_Amrithsar_7.jpg&w=800&output=webp';
      default:
        return 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?q=80&w=1200&auto=format&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Softer background
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPremiumPlaceCard(_filteredPlaces[index]);
                },
                childCount: _filteredPlaces.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
        title: Text(
          '${widget.religion} Activities',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _getHeaderImage(widget.religion),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search by name or location...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPlaceCard(PlaceOfWorship place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: place.themeColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: place.themeColor.withOpacity(0.1),
                ),
                child: Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                  headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image_not_supported, size: 40, color: place.themeColor.withOpacity(0.5)),
                    );
                  },
                ),
              ),
              // Gradient Overlay for text readability
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Type Tag
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance, size: 14, color: place.themeColor),
                      const SizedBox(width: 6),
                      Text(
                        place.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: place.themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Title & Location over image
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          place.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Body content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viewing activities for ${place.name}')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: place.themeColor,
                          side: BorderSide(color: place.themeColor.withOpacity(0.3), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note, size: 20),
                            SizedBox(width: 8),
                            Text('Activities', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing donation for ${place.name}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: place.themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Donate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBackgroundIcon(String religion) {
    switch (religion) {
      case 'Hindu':
        return Icons.brightness_high; // Sun-like icon
      case 'Muslim':
        return Icons.dark_mode; // Crescent-like
      case 'Christian':
        return Icons.add; // Cross-like
      default:
        return Icons.spa;
    }
  }
}
