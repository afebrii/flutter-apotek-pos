import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/doctor_model.dart';

class DoctorListItem extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback? onTap;

  const DoctorListItem({
    super.key,
    required this.doctor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(25),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Doctor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (doctor.specialization != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (doctor.sipNumber != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.sipNumber!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (doctor.hospitalClinic != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.hospitalClinic!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Phone
              if (doctor.phone != null)
                IconButton(
                  icon: const Icon(Icons.phone_outlined),
                  color: AppColors.primary,
                  onPressed: () {
                    // Could launch phone dialer
                  },
                ),

              // Arrow
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
